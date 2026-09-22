{ inputs, self, ... }:

{
  perSystem = { pkgs, ... }:
    let
      mattermost-focus = pkgs.writeShellApplication {
        name = "mattermost-focus";
        runtimeInputs = [ pkgs.niri pkgs.nushell ];
        text = ''
          exec nu ${./focus.nu}
        '';
      };
    in
    {
      packages.mattermost-desktop = inputs.wrapper-modules.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.mattermost-desktop.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            ./patches/default-server.patch
            ./patches/tray-focus.patch
          ];
          postFixup = (old.postFixup or "") + ''
            wrapProgram $out/bin/mattermost-desktop \
              --add-flags "--ozone-platform=x11"
          '';
        });
        env = {
          NIXOS_OZONE_WL = "";
          ELECTRON_OZONE_PLATFORM_HINT = "x11";
        };
        runtimePkgs = [ mattermost-focus ];
      };
    };

  flake.nixosModules.mattermost = { pkgs, lib, ... }:
    {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.mattermost-desktop
      ];

      systemd.user.services.mattermost = {
        description = "Mattermost Desktop";
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.mattermost-desktop;
          Restart = "no";
        };
      };
    };
}
