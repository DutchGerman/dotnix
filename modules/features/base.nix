{ ... }:

{
  flake.nixosModules.base = { config, lib, pkgs, ... }:
    {
      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [ "vscode" ];

      networking.hostName = "nixos";
      networking.networkmanager.enable = true;
      time.timeZone = "Europe/Berlin";
      i18n.defaultLocale = "en_US.UTF-8";

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      users.users.svisser = {
        isNormalUser = true;
        description = "NixOS user";
        extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
      };

      programs.xwayland.enable = true;

      security.polkit.enable = true;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      services.printing.enable = true;
      hardware.bluetooth.enable = true;

      environment.systemPackages = with pkgs; [
        curl wget unzip zip tree htop btop ripgrep fd jq fastfetch wl-clipboard
      ];

      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nix.settings.auto-optimise-store = true;
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };

      system.stateVersion = "25.11";
    };
}
