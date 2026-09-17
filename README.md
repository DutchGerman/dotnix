# NixOS laptop dotfiles

Flake-based NixOS configuration for the `svisser` user, with Niri + Noctalia,
Git/GitHub CLI, SSH tools, VS Code, OpenCode, and common laptop essentials.
It uses NixOS modules and wrapped packages; Home Manager is not required.

## Install

These commands work from a fresh NixOS installation and use temporary Nix
shells for tools that may not be installed yet.

### 1. Get the repository

Replace the URL with your Git repository URL:

```sh
nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git --command git clone https://github.com/DutchGerman/dotnix.git ~/dotnix
cd ~/dotnix
```

### 2. Generate the hardware file

```sh
nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
```

### 3. Review the configuration

Update these values before applying the configuration:

- `username` and `nixosConfigurations` in `flake.nix`
- `networking.hostName` and `time.timeZone` in `modules/features/base.nix`
- `system.stateVersion`, which should normally match the release used for the
  original NixOS installation

### 4. Check and apply

```sh
nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git \
  --command nix --extra-experimental-features 'nix-command flakes' flake check
sudo nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git \
  --command env NIX_CONFIG='extra-experimental-features = nix-command flakes' \
  nixos-rebuild switch --flake .#work-laptop
```

Log out, choose the Niri session in GDM, and log back in.

SSH private keys are intentionally not stored in this repository. Add them to
`~/.ssh` and use `ssh-add` after logging in.

## Structure

The flake uses `flake-parts` and `import-tree`; every Nix file under `modules/`
is loaded as a flake module automatically.

- `modules/hosts/nixos/` defines the `nixos` host and assembles its modules.
- `modules/features/base.nix` contains core NixOS settings and essentials.
- `modules/features/niri.nix` wraps Niri and contains its keybindings.
- `modules/features/noctalia.nix` enables the Noctalia shell and services.
- `modules/features/git.nix` wraps Git and defines its defaults.
- `modules/features/gh.nix` installs the GitHub CLI.
- `modules/features/vscode.nix` installs VS Code.
- `modules/features/opencode.nix` installs OpenCode.
- `modules/features/firefox.nix` enables Firefox.
- `modules/features/ssh.nix` contains OpenSSH and SSH management tools.
- `modules/features/environment.nix` defines the wrapped login environment and
  Wayland variables.

## Updating

```sh
nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git \
  --command nix --extra-experimental-features 'nix-command flakes' flake update
sudo nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git \
  --command env NIX_CONFIG='extra-experimental-features = nix-command flakes' \
  nixos-rebuild switch --flake .#work-laptop
```
