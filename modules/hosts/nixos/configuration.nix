{ ... }:

{
  flake.nixosModules.nixosConfiguration = { self, ... }:
    {
      imports = [
        ../../../hosts/nixos/hardware-configuration.nix
        self.nixosModules.base
        self.nixosModules.foot
        self.nixosModules.niri
        self.nixosModules.noctalia
        self.nixosModules.luciole
        self.nixosModules.removable-media
        self.nixosModules.mattermost
        self.nixosModules.git
        self.nixosModules.gh
        self.nixosModules.howdy
        self.nixosModules.vscode
        self.nixosModules.opencode
        self.nixosModules.firefox
        self.nixosModules.environment
        self.nixosModules.direnv
        self.nixosModules.zsh
        self.nixosModules.ssh
      ];
    };
}
