{ inputs, self, ... }:

{
  perSystem = { pkgs, lib, ... }:
    let
      mattermost-focus = pkgs.writeShellApplication {
        name = "mattermost-focus";
        runtimeInputs = [ pkgs.niri pkgs.nushell ];
        text = ''
          # shellcheck disable=SC2016
          nu -c '
            let window = (niri msg --json windows | from json | where { |window|
              (($window.app_id? | default "" | str lowercase) == "mattermost.desktop")
            } | get 0?)

            if ($window | is-empty) {
              exit 1
            }

            niri msg action focus-window --id $window.id
          '
        '';
      };
    in
    {
      packages.mattermost-desktop = inputs.wrapper-modules.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.mattermost-desktop.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.nushell ];
          postPatch = old.postPatch + ''
            nu -c '
              let path = "src/common/config/buildConfig.ts"
              let servers = [
                "defaultServers: ["
                "    {"
                "        name: \"apm E-Campus\","
                "        url: \"https://mattermost.apm-ecampus.de\","
                "    },"
                "],"
              ] | str join (char newline)

              open --raw $path
              | str replace --all --regex "(?s)defaultServers: \\[/\\*.*?\\*/\\]," $servers
              | save --force $path

            let tray_path = "src/app/system/tray/tray.ts"
            open --raw $tray_path
            | str replace --regex "import path from .path.;" "import {execFileSync} from \"child_process\";\n\nimport path from \"path\";"
            | str replace "        // At minimum show the main window\n        MainWindow.show();" "        try {\n            execFileSync(\"${lib.getExe mattermost-focus}\");\n            return;\n        } catch {\n            // No Mattermost window is currently mapped; create one below.\n        }\n\n        // At minimum show the main window\n        MainWindow.show();"
            | save --force $tray_path
            '
          '';
          postFixup = (old.postFixup or "") + ''
            wrapProgram $out/bin/mattermost-desktop \
              --add-flags "--ozone-platform=x11"
          '';
        });
        env = {
          NIXOS_OZONE_WL = "";
          ELECTRON_OZONE_PLATFORM_HINT = "x11";
        };
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
