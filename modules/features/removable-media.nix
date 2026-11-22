{ ... }:

{
  flake.nixosModules.removable-media = { pkgs, ... }:
    {
      services.udisks2.enable = true;
      environment.systemPackages = [ pkgs.udiskie ];
      systemd.user.services.udiskie = {
        description = "Automount removable media";
        wantedBy = [ "default.target" ];
        serviceConfig.ExecStart = "${pkgs.udiskie}/bin/udiskie";
      };
    };
}
