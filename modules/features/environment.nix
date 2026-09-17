{ inputs, self, ... }:

{
  perSystem = { pkgs, lib, self', ... }:
    {
      packages.environment = inputs.wrapper-modules.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.zsh;
        runtimePkgs = with pkgs; [
          curl wget unzip zip tree htop btop ripgrep fd jq fastfetch
          openssh sshfs keychain seahorse wl-clipboard
          self'.packages.git
        ];
        env = {
          NIXOS_OZONE_WL = "1";
          MOZ_ENABLE_WAYLAND = "1";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          EDITOR = lib.getExe pkgs.vim;
        };
      };
    };

  flake.nixosModules.environment = { pkgs, ... }:
    let
      shellPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.environment;
      shellPath = "${shellPackage}/bin/zsh";
    in {
      users.users.svisser.shell = shellPath;
      environment.shells = [ shellPath ];
        environment.sessionVariables = {
          NIXOS_OZONE_WL = "1";
          MOZ_ENABLE_WAYLAND = "1";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          XDG_CURRENT_DESKTOP = "GNOME";
          XDG_SESSION_DESKTOP = "niri";
        };
    };
}
