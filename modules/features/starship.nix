{ inputs, ... }:

{
  perSystem = { pkgs, ... }:
    {
      packages.starship = inputs.wrapper-modules.wrappers.starship.wrap {
        inherit pkgs;
        settings = {
          add_newline = true;
          format = "$directory$git_branch$git_status$nix_shell$cmd_duration$line_break$character";
          directory = {
            style = "bold #89b4fa";
            truncation_length = 3;
            truncation_symbol = ".../";
          };
          git_branch = {
            symbol = "on ";
            style = "bold #cba6f7";
          };
          git_status.style = "bold #f9e2af";
          nix_shell = {
            symbol = "nix ";
            style = "bold #94e2d5";
          };
          cmd_duration = {
            min_time = 2000;
            style = "bold #fab387";
          };
          character = {
            success_symbol = "[>](bold #a6e3a1)";
            error_symbol = "[>](bold #f38ba8)";
          };
        };
      };
    };
}
