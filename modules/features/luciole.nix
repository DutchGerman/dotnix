{ inputs, ... }:

{
  flake.nixosModules.luciole = { ... }:
    {
      imports = [ inputs.luciole.nixosModules.default ];

      programs.luciole.enable = true;
      services.gvfs.enable = true;
    };
}
