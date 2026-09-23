{ inputs, ... }:

{
  flake.nixosModules.noctalia = { pkgs, lib, username, ... }:
    let
      noctalia = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      paletteFiles = {
        Spring = ./themes/spring/palette.json;
        Summer = ./themes/summer/palette.json;
        Autumn = ./themes/autumn/palette.json;
        Winter = ./themes/winter/palette.json;
      };
      configFile = pkgs.writeText "noctalia.toml" ''
        # Coordinates are Berlin's. Change them if the laptop is used elsewhere.
        [location]
        latitude = 52.5200
        longitude = 13.4050

        [theme]
        mode = "auto"
        shell_mode = "follow"
        source = "custom"
        custom_palette = "Spring"

        [lockscreen]
        enabled = true
        blurred_desktop = false
        blur_intensity = 0.0
        tint_intensity = 0.35
        wallpaper = ""
      '';
      syncWallpaper = pkgs.writeShellScript "noctalia-sync-wallpaper" ''
        case "$(${pkgs.coreutils}/bin/date +%m)" in
          09|10|11) ;;
          *) exit 0 ;;
        esac

        mode="$(${lib.getExe noctalia} msg theme-mode-get)"
        case "$mode" in
          light) wallpaper="$HOME/.config/noctalia/themes/autumn/day.jpg" ;;
          dark) wallpaper="$HOME/.config/noctalia/themes/autumn/night.jpg" ;;
          *) exit 1 ;;
        esac
        current="$(${lib.getExe noctalia} msg wallpaper-get)"

        if [ "$current" != "$wallpaper" ]; then
          exec ${lib.getExe noctalia} msg wallpaper-set "$wallpaper"
        fi
      '';
      selectSeason = pkgs.writeShellScript "noctalia-select-season" ''
        case "$(${pkgs.coreutils}/bin/date +%m)" in
          03|04|05) season=Spring ;;
          06|07|08) season=Summer ;;
          09|10|11) season=Autumn ;;
          12|01|02) season=Winter ;;
        esac

        ${lib.getExe noctalia} msg color-scheme-set custom "$season"
        exec ${syncWallpaper}
      '';
    in
    {
      programs.noctalia = {
        enable = true;
        package = noctalia;
        systemd.enable = true;
        recommendedServices.enable = true;
      };

      systemd.user.tmpfiles.users.${username}.rules = [
        "d %h/.config/noctalia 0755 - - -"
        "d %h/.config/noctalia/palettes 0755 - - -"
        "d %h/.config/noctalia/themes/autumn 0755 - - -"
        "L+ %h/.config/noctalia/noctalia.toml - - - - ${configFile}"
        "L+ %h/.config/noctalia/themes/autumn/day.jpg - - - - ${./themes/autumn/day.jpg}"
        "L+ %h/.config/noctalia/themes/autumn/night.jpg - - - - ${./themes/autumn/night.jpg}"
      ] ++ lib.mapAttrsToList (name: file:
        "L+ %h/.config/noctalia/palettes/${name}.json - - - - ${file}") paletteFiles;

      systemd.user.services.noctalia-season = {
        description = "Select the Noctalia palette for the current season";
        after = [ "noctalia.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = selectSeason;
        };
      };

      systemd.user.timers.noctalia-season = {
        description = "Update the Noctalia palette at seasonal boundaries";
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        timerConfig = {
          OnActiveSec = "10s";
          OnCalendar = [ "*-03-01 00:05:00" "*-06-01 00:05:00" "*-09-01 00:05:00" "*-12-01 00:05:00" ];
          Persistent = true;
          Unit = "noctalia-season.service";
        };
      };

      systemd.user.services.noctalia-wallpaper = {
        description = "Synchronize the Noctalia wallpaper with its resolved theme mode";
        after = [ "noctalia.service" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = syncWallpaper;
        };
      };

      systemd.user.timers.noctalia-wallpaper = {
        description = "Check the Noctalia day and night wallpaper every minute";
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        timerConfig = {
          OnStartupSec = "30s";
          OnUnitActiveSec = "1min";
          Unit = "noctalia-wallpaper.service";
        };
      };
    };
}
