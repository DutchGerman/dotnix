{ inputs, self, ... }:

{
  perSystem = { pkgs, ... }:
    {
      packages.git = inputs.wrapper-modules.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.git;
        env = {
          GIT_CONFIG_COUNT = "3";
          GIT_CONFIG_KEY_0 = "init.defaultBranch";
          GIT_CONFIG_VALUE_0 = "main";
          GIT_CONFIG_KEY_1 = "pull.rebase";
          GIT_CONFIG_VALUE_1 = "true";
          GIT_CONFIG_KEY_2 = "push.autoSetupRemote";
          GIT_CONFIG_VALUE_2 = "true";
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
