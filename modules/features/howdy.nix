{ ... }:

{
  flake.nixosModules.howdy = {
    services.howdy = {
      enable = true;
      control = "sufficient";
    };
  };
}
