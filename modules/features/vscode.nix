{ inputs, self, ... }:

{
  flake.nixosModules.vscode = { pkgs, ... }:
    {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.vscode
      ];
    };

  perSystem = { pkgs, ... }:
    {
      packages.vscode = inputs.wrapper-modules.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.vscode;
        flags = {
          "--password-store" = "gnome-libsecret";
        };
      };
    };
}
