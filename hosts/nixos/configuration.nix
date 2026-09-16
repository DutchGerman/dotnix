{ config, lib, pkgs, username, noctalia, ... }:

{
  imports = [
    # Replace the placeholder with this command's output:
    # nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.displayManager.gdm.enable = true;
  services.gnome.gnome-keyring.enable = true;

  programs.niri.enable = true;
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

  users.users.${username} = {
    isNormalUser = true;
    description = "NixOS user";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.git.enable = true;
  programs.ssh.startAgent = true;

  environment.systemPackages = with pkgs; [
    curl wget unzip zip tree htop btop ripgrep fd jq fastfetch wl-clipboard
    openssh keychain sshfs seahorse
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit username noctalia; };
    users.${username} = import ../../home/nixos.nix;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  system.stateVersion = "25.11";
}
