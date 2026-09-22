{ inputs, self, ... }:

{
  perSystem = { pkgs, ... }:
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
