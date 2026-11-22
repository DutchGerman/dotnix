{ self, ... }:

{
  flake.nixosModules.nixosConfiguration = { self, inputs, username, pkgs, ... }:
    {
      services.udisks2.enable = true;
      environment.systemPackages = [ pkgs.udiskie ];
      systemd.user.services.udiskie = {
        description = "Automount removable media";
        wantedBy = [ "default.target" ];
        serviceConfig.ExecStart = "${pkgs.udiskie}/bin/udiskie";
      };

      imports = [
        ../../../hosts/nixos/hardware-configuration.nix
        self.nixosModules.base
        self.nixosModules.foot
        self.nixosModules.niri
        self.nixosModules.noctalia
        self.nixosModules.luciole
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
