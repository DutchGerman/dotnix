{ inputs, self, ... }:

{
  flake.nixosModules.niri = { pkgs, ... }:
    let
      autumnDark = (builtins.fromJSON (builtins.readFile ./noctalia/themes/autumn/palette.json)).dark;
    in
    {
      services.displayManager.noctalia-greeter = {
        enable = true;
        settings.auth = {
          allow_empty_password = true;
          request_timeout = 0;
        };
        settings.appearance = {
          scheme = "Synced";
          theme_mode = "dark";
          scheme_selector_position = "hidden";
          palette = {
            primary = autumnDark.mPrimary;
            on_primary = autumnDark.mOnPrimary;
            secondary = autumnDark.mSecondary;
            on_secondary = autumnDark.mOnSecondary;
            tertiary = autumnDark.mTertiary;
            on_tertiary = autumnDark.mOnTertiary;
            error = autumnDark.mError;
            on_error = autumnDark.mOnError;
            surface = autumnDark.mSurface;
            on_surface = autumnDark.mOnSurface;
            surface_variant = autumnDark.mSurfaceVariant;
            on_surface_variant = autumnDark.mOnSurfaceVariant;
            outline = autumnDark.mOutline;
            shadow = autumnDark.mShadow;
            hover = autumnDark.mHover;
            on_hover = autumnDark.mOnHover;
          };
          wallpaper = {
            path = "${./noctalia/themes/autumn/night.jpg}";
            fill_mode = "crop";
          };
        };
      };
      services.gnome.gnome-keyring.enable = true;
      security.pam.services.login.howdy.enable = false;

      programs.niri = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
      };
    };

  perSystem = { pkgs, lib, self', ... }:
    let
      autumnLight = (builtins.fromJSON (builtins.readFile ./noctalia/themes/autumn/palette.json)).light;
    in
    {
      packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        settings = {
          spawn-at-startup = [
            (lib.getExe inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default)
          ];
          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
          input.keyboard.xkb.layout = "us";
          layout.gaps = 8;
          layout.center-focused-column = "never";
          layout.default-column-width.proportion = 0.5;
          layout.focus-ring = {
            width = 3;
            active-color = autumnLight.mPrimary;
            inactive-color = autumnLight.mSurfaceVariant;
            urgent-color = autumnLight.mError;
          };
          prefer-no-csd = true;
          screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";
          window-rules = [
            {
              opacity = 0.96;
            }
          ];
          binds = {
            "Mod+Return".spawn-sh = lib.getExe self'.packages.foot;
            "Mod+D".spawn-sh = "${lib.getExe inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default} ipc call launcher toggle";
            "Mod+Q".close-window = _: { };
            "Mod+Shift+E".quit = _: { };
            "Mod+H".focus-column-left = _: { };
            "Mod+Left".focus-column-left = _: { };
            "Mod+J".focus-window-down = _: { };
            "Mod+K".focus-window-up = _: { };
            "Mod+L".focus-column-right = _: { };
            "Mod+Right".focus-column-right = _: { };
            "Mod+Down".focus-workspace-down = _: { };
            "Mod+Up".focus-workspace-up = _: { };
            "Mod+1".focus-workspace = 1;
            "Mod+2".focus-workspace = 2;
            "Mod+3".focus-workspace = 3;
            "Mod+Shift+1".move-column-to-workspace = 1;
            "Mod+Shift+2".move-column-to-workspace = 2;
            "Mod+Shift+3".move-column-to-workspace = 3;
            "Mod+F".maximize-column = _: { };
            "Mod+Shift+F".fullscreen-window = _: { };
            "Mod+Equal".set-column-width = "+10%";
            "Mod+Minus".set-column-width = "-10%";
            "Mod+Shift+Equal".set-window-height = "+10%";
            "Mod+Shift+Minus".set-window-height = "-10%";
            "Print".screenshot = _: { };
          };
        };
      };
    };
}
