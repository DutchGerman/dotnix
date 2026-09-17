{ inputs, ... }:

{
  flake.nixosModules.noctalia = { pkgs, ... }:
    {
      programs.noctalia = {
        enable = true;
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
        systemd.enable = true;
        recommendedServices.enable = true;
      };
    };
}
