{ inputs, self, ... }:

{
  perSystem = { pkgs, lib, ... }:
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
        package = (pkgs.mattermost-desktop.override {
          # FIXME: Electron 43.3+ no longer registers Mattermost's StatusNotifier item correctly:
          # https://github.com/electron/electron/issues/52674
          electron_43 = pkgs.electron_42;
        }).overrideAttrs (old: {
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
          MATTERMOST_FOCUS_COMMAND = lib.getExe mattermost-focus;
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
