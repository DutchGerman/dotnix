{ inputs, self, ... }:

{
  perSystem = { pkgs, ... }:
    {
      packages.git = inputs.wrapper-modules.wrappers.git.wrap {
        inherit pkgs;
        settings = {
          user = {
            name = "Stefan Visser";
            email = "stefan.visser@apm-ecampus.de";
          };
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
        };
      };
    };

  flake.nixosModules.git = { pkgs, ... }:
    {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.git
        pkgs.git-lfs
      ];
    };
}
