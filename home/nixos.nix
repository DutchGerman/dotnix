{ config, pkgs, lib, username, noctalia, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [ vscode gh opencode git-lfs just unzip zip ];
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  programs.gh.enable = true;

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    extraConfig = ''
      Host *
        ServerAliveInterval 60
        ServerAliveCountMax 3
        ControlMaster auto
        ControlPath ~/.ssh/control-%C
        ControlPersist 10m
    '';
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -lah";
      rebuild = "sudo nixos-rebuild switch --flake ~/dotnix#nixos";
      update = "nix flake update ~/dotnix";
    };
  };

  programs.noctalia = {
    enable = true;
    package = noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    systemd.enable = true;
    settings = {
      bar = {
        position = "top";
        density = "comfortable";
      };
      wallpaper.enabled = true;
    };
  };

  xdg.configFile."niri/config.kdl".text = ''
    input {
        keyboard { xkb { layout "us" } }
        focus-follows-mouse
    }
    layout {
        gaps 8
        center-focused-column "never"
        default-column-width { proportion 0.5; }
    }
    prefer-no-csd
    screenshot-path "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png"
    spawn-at-startup "noctalia"
    spawn-at-startup "xwayland-satellite"
    binds {
        Mod+Return { spawn "foot"; }
        Mod+D { spawn "noctalia" "ipc" "call" "launcher" "toggle"; }
        Mod+Q { close-window; }
        Mod+Shift+E { quit; }
        Mod+H { focus-column-left; }
        Mod+J { focus-window-down; }
        Mod+K { focus-window-up; }
        Mod+L { focus-column-right; }
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Print { screenshot; }
    }
  '';

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
}
