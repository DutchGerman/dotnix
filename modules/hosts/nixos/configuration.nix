{ self, ... }:

{
  flake.nixosModules.nixosConfiguration = { self, inputs, username, ... }:
    {
      imports = [
        ../../../hosts/nixos/hardware-configuration.nix
        self.nixosModules.base
        self.nixosModules.niri
        self.nixosModules.noctalia
        self.nixosModules.git
        self.nixosModules.gh
        self.nixosModules.vscode
        self.nixosModules.opencode
        self.nixosModules.environment
        self.nixosModules.ssh
      ];
    };
}
