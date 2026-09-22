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
        package = pkgs.vscode-with-extensions.override {
          vscodeExtensions = [
            pkgs.vscode-extensions.jnoortheen.nix-ide
            pkgs.vscode-extensions.thenuprojectcontributors.vscode-nushell-lang
            pkgs.vscode-extensions.vue.volar
          ];
        };
        runtimePkgs = [
          pkgs.nixd
          pkgs.nixfmt
        ];
        flags = {
          "--password-store" = "gnome-libsecret";
        };
        env = {
          XDG_CURRENT_DESKTOP = "GNOME";
          XDG_SESSION_DESKTOP = "niri";
        };
      };
    };
}
