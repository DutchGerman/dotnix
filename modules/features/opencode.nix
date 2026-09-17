{ inputs, ... }:

{
  flake.nixosModules.opencode = { pkgs, ... }:
    {
      environment.systemPackages = [
        inputs.nixpkgs-opencode.legacyPackages.${pkgs.stdenv.hostPlatform.system}.opencode
      ];
    };
}
