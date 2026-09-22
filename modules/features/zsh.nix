{ inputs, self, ... }:

{
  perSystem = { pkgs, lib, self', ... }:
    {
      packages.zsh = inputs.wrapper-modules.wrappers.zsh.wrap {
        inherit pkgs;
        runtimePkgs = with pkgs; [
          curl wget unzip zip tree htop btop ripgrep fd jq fastfetch
          bat eza zoxide zsh-autosuggestions zsh-syntax-highlighting
          openssh sshfs keychain seahorse wl-clipboard
          self'.packages.git
          self'.packages.starship
        ];
        env = {
          NIXOS_OZONE_WL = "1";
          MOZ_ENABLE_WAYLAND = "1";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          EDITOR = lib.getExe pkgs.vim;
        };
        zshrc.content = ''
          HISTFILE="''${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
          HISTSIZE=10000
          SAVEHIST=10000
          mkdir -p "''${HISTFILE:h}"
          fc -R "$HISTFILE"
          setopt append_history inc_append_history share_history
          setopt hist_expire_dups_first hist_ignore_all_dups hist_save_no_dups

          autoload -Uz compinit
          compinit

          source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
          eval "$(${lib.getExe pkgs.zoxide} init zsh)"
          eval "$(${lib.getExe self'.packages.starship} init zsh)"
          source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

           alias ls='eza --group-directories-first'
           alias ll='eza --long --git --group-directories-first'
           alias cat='bat'
           alias dotnix='cd ~/dotnix'
           alias rebuild='sudo nixos-rebuild switch --flake ~/dotnix#work-laptop'
         '';
      };
    };

  flake.nixosModules.zsh = { pkgs, ... }:
    let
      shellPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.zsh;
      shellPath = "${shellPackage}/bin/zsh";
    in {
      users.users.svisser.shell = shellPath;
      environment.shells = [ shellPath ];
    };
}
