# NixOS laptop dotfiles

Flake-based NixOS configuration for the `svisser` user, with Niri + Noctalia,
Git/GitHub CLI, SSH tools, VS Code, OpenCode, and common laptop essentials.

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
- `networking.hostName` and `time.timeZone` in `hosts/nixos/configuration.nix`
- `system.stateVersion`, which should normally match the release used for the
  original NixOS installation

### 4. Check and apply

```sh
nix --extra-experimental-features 'nix-command flakes' flake check
sudo env NIX_CONFIG='extra-experimental-features = nix-command flakes' nixos-rebuild switch --flake .#nixos
```

Log out, choose the Niri session in GDM, and log back in.

SSH private keys are intentionally not stored in this repository. Add them to
`~/.ssh` and use `ssh-add` after logging in.

## Updating

```sh
nix --extra-experimental-features 'nix-command flakes' flake update
sudo env NIX_CONFIG='extra-experimental-features = nix-command flakes' nixos-rebuild switch --flake .#nixos
```
