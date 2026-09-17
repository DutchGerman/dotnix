---
name: nix
description: Use this skill when working with NixOS, flakes, flake-parts modules, nix-wrapper-modules, packages, or Nix commands in this repository.
---

# Nix

Use this skill for all Nix-related work in this repository.

## Repository architecture

- The flake is built with `flake-parts` and `import-tree`.
- `flake.nix` should stay a small entry point. Modules under `modules/` are
  loaded automatically by `import-tree`.
- Keep features separated by concern. For example, Git, GitHub CLI, VS Code,
  OpenCode, Niri, Noctalia, Firefox, SSH, and the shell environment each have
  their own feature module.
- Host assembly belongs under `modules/hosts/<host>/`.
- Hardware-specific configuration belongs under `hosts/<host>/` and should be
  generated with `nixos-generate-config` rather than hand-written.
- This configuration intentionally does not use Home Manager. Use NixOS
  modules, packages, and wrapped executables instead.

## Flake-parts conventions

Prefer a flake-parts module for new Nix code:

```nix
{ ... }:
{
  flake.nixosModules.example = { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.example ];
    };
}
```

For a package that is specialized per system, define it in `perSystem`:

```nix
{ inputs, ... }:
{
  perSystem = { pkgs, ... }:
    {
      packages.example = inputs.wrapper-modules.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.example;
      };
    };
}
```

The host module can install the package through the system-specific self
output:

```nix
{ self, ... }:
{
  flake.nixosModules.example = { pkgs, ... }:
    {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.example
      ];
    };
}
```

Inside `perSystem`, prefer `self'` for the current system's self outputs and
`inputs'` for system-specialized inputs. Do not use a literal
`x86_64-linux` when the value can be derived from `system` or
`pkgs.stdenv.hostPlatform.system`. Do not introduce `withSystem` merely to
access a package already available through `self'`; use `withSystem` only when
crossing from a top-level module into a particular system context is actually
necessary.

Remember to declare supported systems with the flake-parts `systems` option,
for example:

```nix
{ systems = [ "x86_64-linux" ]; }
```

Without this, expected `packages` outputs may not be generated.

## nix-wrapper-modules

Use the wrapper library when a program should carry its configuration with the
executable. This keeps configuration portable and avoids depending on a
Home Manager installation.

For simple wrappers, use `wrapPackage`:

```nix
inputs.wrapper-modules.lib.wrapPackage {
  inherit pkgs;
  package = pkgs.some-program;
  runtimePkgs = [ pkgs.some-runtime-dependency ];
  env = {
    SOME_VARIABLE = "value";
  };
}
```

The runtime dependency option is library-version-specific. Check the locked
wrapper input before using it; for example, the current library uses
`runtimePkgs`, while older wrapper libraries may use `runtimeInputs`.

Before writing a custom wrapper, check the available prebuilt modules in the
[nix-wrapper-modules catalog](https://nix-community.github.io/nix-wrapper-modules/md/wrapper-modules.html).
Then verify the module's current name and options against the version pinned
by `flake.lock`, since the catalog and the pinned input may differ.

Prefer a prebuilt wrapper module when one exists. Inspect its documentation or
source to determine the module name and configuration options. A dedicated
wrapper usually provides typed settings and generates the program's config
file, which is preferable to manually assembling environment variables.

For example, a Git wrapper may expose a structured `settings` option and a
`configFile` option for additional raw configuration. Keep user-specific
identity, credentials, and other values in the consuming configuration rather
than hard-coding them in a reusable skill or example.

When wrapping Niri, use the wrapper's current action syntax. Empty actions are
functions such as `_: { }`, not `null`; `null` may be rendered as invalid KDL.
Use `lib.getExe` for executable paths where possible.

## NixOS integration

Each feature should expose a NixOS module, and the host should import only the
features it uses. Keep package construction in `perSystem` and installation or
NixOS options in `flake.nixosModules.<name>`.

For a wrapped shell, `users.users.<name>.shell` must point to the executable,
for example `${shellPackage}/bin/zsh`, and that executable must also be listed
in `environment.shells`. A derivation path alone is not a valid shell.

Avoid conflicting service providers. For example, do not enable both
`programs.ssh.startAgent` and `services.gnome.gcr-ssh-agent.enable`; only one
SSH-agent implementation may be active.

Allow unfree packages in the relevant nixpkgs evaluation. Prefer a narrow
predicate when possible, such as allowing only `vscode`, rather than enabling
all unfree packages globally.

## Commands and debugging

Use Nix's modern CLI:

```bash
nix flake show
nix flake metadata
nix flake check
nix eval .#packages.x86_64-linux --apply builtins.attrNames
nix build .#packages.x86_64-linux.<name> --print-out-paths --no-link
sudo nixos-rebuild switch --flake .#work-laptop
```

If experimental features are not enabled, add:

```bash
--extra-experimental-features 'nix-command flakes'
```

When diagnosing an evaluation error, read the innermost failed option or
assertion first. Common issues in this repository have included:

- using an output that was never exposed because `systems` was missing;
- using the wrong system attribute instead of `self'` or the current host
  platform;
- passing `null` to a wrapper option that expects an action function;
- assigning a derivation instead of its `/bin/<executable>` as a shell;
- selecting an unfree package without a matching nixpkgs policy; and
- importing or defining a flake output more than once.

Prefer focused `nix build` or `nix eval` commands while iterating, then run
`nix flake check` before handing off the change. Never put private keys,
passwords, tokens, or other secrets in the flake.

## Style

- Prefer explicit attribute access over `with`.
- Avoid `callPackage` when direct arguments or `pkgs.<name>` are clearer.
- Avoid unnecessary `rec`, overlays, abstractions, and new dependencies.
- Keep lock-file changes intentional and explain them when they are required.
- Preserve user changes in a dirty worktree and do not reset or overwrite
  unrelated files.
