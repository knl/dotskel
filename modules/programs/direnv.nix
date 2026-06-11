{ config, lib, pkgs, ... }:

{
  config = {
    programs.direnv = {
      enable = true;
      # The stock hook forks `direnv export zsh` on every prompt; the
      # signature-gated hook below replaces it.
      enableZshIntegration = false;
      nix-direnv.enable = true;
    };

    # z4h-style direnv hook: keep a signature over the closest .envrc (its
    # path, plus mtimes of it, direnv's allow db and config) and fork
    # `direnv export zsh` only when the signature changes. Prompts where
    # nothing changed cost a few stat() calls and no forks. Tradeoff: edits
    # to files watched from inside .envrc (e.g. flake.nix via nix-direnv's
    # watch_file) are only picked up after `direnv reload`.
    programs.zsh.initContent = ''
      zmodload -F zsh/stat b:zstat

      _direnv_hook() {
        emulate -L zsh -o extended_glob
        local sig envrc=(./(../)#.envrc(NY1:a))
        if (( $#envrc )); then
          local -a mtimes
          zstat -A mtimes +mtime -- $envrc \
              ''${XDG_DATA_HOME:-~/.local/share}/direnv/allow(N) \
              ''${XDG_CONFIG_HOME:-~/.config}/direnv/{direnv,config}.toml(N) 2>/dev/null \
            || mtimes=(stat-error)
          sig="$envrc"$'\0'"''${(pj:\0:)mtimes}"
        elif [[ ! -v DIRENV_WATCHES ]]; then
          # Fast path: no .envrc up the tree and no env loaded.
          typeset -g _direnv_sig=none
          return 0
        else
          sig=none  # .envrc gone but env still loaded: unload below
        fi
        [[ $sig == "''${_direnv_sig-}" ]] && return 0
        trap -- "" INT
        eval "$(${lib.getExe config.programs.direnv.package} export zsh)"
        trap - INT
        typeset -g _direnv_sig=$sig
      }

      typeset -ag precmd_functions
      if (( ! ''${precmd_functions[(I)_direnv_hook]} )); then
        precmd_functions=(_direnv_hook $precmd_functions)
      fi
      typeset -ag chpwd_functions
      if (( ! ''${chpwd_functions[(I)_direnv_hook]} )); then
        chpwd_functions=(_direnv_hook $chpwd_functions)
      fi
    '';
  };
}
