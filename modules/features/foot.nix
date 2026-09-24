{ inputs, self, ... }:

{
  flake.nixosModules.foot = { pkgs, ... }:
    {
      fonts.packages = [ pkgs.jetbrains-mono ];
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.foot
      ];
    };

  perSystem = { pkgs, self', ... }:
    {
      packages.foot = inputs.wrapper-modules.wrappers.foot.wrap {
        inherit pkgs;
        settings = {
          main = {
            font = "JetBrains Mono:size=13";
            shell = "${self'.packages.zsh}/bin/zsh";
            pad = "10x10";
            dpi-aware = "yes";
            bold-text-in-bright = "yes";
          };
          scrollback.lines = 10000;
          key-bindings = {
            clipboard-copy = "Control+c";
            clipboard-paste = "Control+v";
          };
          cursor = {
            style = "beam";
            blink = "yes";
          };
          "colors-dark" = {
            foreground = "cdd6f4";
            background = "1e1e2e";
            "selection-foreground" = "cdd6f4";
            "selection-background" = "585b70";
            regular0 = "45475a";
            regular1 = "f38ba8";
            regular2 = "a6e3a1";
            regular3 = "f9e2af";
            regular4 = "89b4fa";
            regular5 = "f5c2e7";
            regular6 = "94e2d5";
            regular7 = "bac2de";
            bright0 = "585b70";
            bright1 = "f38ba8";
            bright2 = "a6e3a1";
            bright3 = "f9e2af";
            bright4 = "89b4fa";
            bright5 = "f5c2e7";
            bright6 = "94e2d5";
            bright7 = "a6adc8";
          };
        };
      };
    };
}
