{ inputs, self, ... }:

{
  flake.nixosConfigurations."work-laptop" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs self;
      username = "svisser";
    };
    modules = [
      inputs.noctalia.nixosModules.default
      self.nixosModules.nixosConfiguration
    ];
  };
}
