{ ... }:

{
  flake.nixosModules.ssh = { pkgs, ... }:
    {
      services.gnome.gnome-keyring.enable = true;
      environment.systemPackages = with pkgs; [
        openssh keychain sshfs seahorse
      ];
    };
}
