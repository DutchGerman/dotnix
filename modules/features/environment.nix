{ ... }:

{
  flake.nixosModules.environment = { ... }:
    {
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        XDG_CURRENT_DESKTOP = "GNOME";
        XDG_SESSION_DESKTOP = "niri";
      };
    };
}
