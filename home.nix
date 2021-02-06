{ config, pkgs, ... }:

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  # Allow non-free (as in beer) packages
  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  xdg.enable = true;

  # Packages in alphabetical order, as I can't do categories
  home.packages = with pkgs; [
    exa
    fd
    fortune
    gitAndTools.gitFull
    gitAndTools.hub
    gnused
    htop
    imagemagick
    jq
    loc
    lua
    mtr
    ncdu
    netcat
    niv
    p7zip
    paperkey
    python3
    python3Packages.tvnamer
    readline
    ripgrep
    rsync
    shellcheck
    shfmt
    tree
    xz
    zstd
  ];

  # TODO:
  # Install the following apps (might need nix-darwin)
  # hammerspoon
  # karabiner
  # f.lux
  # textexpander
  # istatmenus
  # trello
  # busycall
  # emacs

  programs.fzf.enable = true;
  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withRuby = false;
    extraConfig = ''
      syntax on
      syntax enable                     " Turn on syntax highlighting allowing local overrides
      set hidden                        " hide buffers instead of removing them
      set number                        " Show line numbers
      set relativenumber                " Show them relative to line
      set ruler                         " Show line and column number
      set termguicolors                 " Use full colors
      set clipboard=unnamed             " Allow for x-app pasting
    '';
  };

  home.file.".emacs.d" = {
      source = sources.spacemacs;
      recursive = true;
    };
  # This creates a symlink to the file, so I can easily edit it
  # Not for the faint of heart, though...
  home.file.".spacemacs".source = link ./spacemacs;

  # home.file.".p10k.zsh".source = ./p10k.zsh;

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
	  userEmail = "nikola@knezevic.ch";
	  userName = "Nikola Knezevic";
    # aliases are defined in ~/.gitaliases
    extraConfig = {
      color = {
        status = "auto";
        diff = "auto";
        branch = "auto";
        ui = "auto";
      };
      rerere.enabled = "true";
      credential.helper = "osxkeychain";
      core.whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
      repack.usedeltabaseoffset = "true";
      diff = {
        renames = "copies";
        mnemonicprefix = "true";
        algorithm = "histogram";
      };
      branch.autosetupmerge = "true";
      push.default = "current";
      merge.stat = "true";
      pull.ff = "only";
    };
    # Replaces ~/.gitignore
    ignores = [
      ".cache/"
      ".DS_Store"
      ".idea/"
      "*.swp"
      "*.elc"
      "auto-save-list"
      ".direnv/"
      # exclude nix-build result
      "result"
      "result-*"
    ];
    # see home.file.".gitaliases".source below
    includes = [
        { path = "~/.gitaliases"; }
    ];
  };
  home.file.".gitaliases".source = ./gitaliases;

  programs.z-lua = {
    enable = true;
    options = ["once" "fzf"];
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    history.extended = true;

    sessionVariables = rec {
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";

      NVIM_TUI_ENABLE_TRUE_COLOR = "1";

      EDITOR = "vim";
      VISUAL = EDITOR;
      GIT_EDITOR = EDITOR;

      GOPATH = "$HOME/go";
      PATH = "$HOME/bin:$GOPATH/bin:$PATH";
      TERM = "xterm-256color";

      LESS = "-F -g -i -M -R -S -w -X -z-4";

      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=8";

      # This is to make `z my-dir` work with z.lua
      _ZL_HYPHEN = "1";

      # This way, C-w deletes words (path elements)
      WORDCHARS = "*?_-.[]~&;!#$%^(){}<>";
    };

    shellAliases = {
      ls = "exa -G --color auto -a -s type";
      ll = "exa -l --color always -a -s type";
      "]" = "open";
      dl = "\curl -O -L";
      up = "\cd ..";
      p = "pushd";
      pd = "perldoc";
      mkdir = "nocorrect mkdir";
    };

    initExtraFirst = ''
      DIRSTACKSIZE=10

      setopt   notify globdots correct cdablevars autolist
      setopt   correctall autocd recexact longlistjobs
      setopt   autoresume
      setopt   extendedglob rcquotes mailwarning
      unsetopt bgnice autoparamslash
      setopt   autopushd pushdminus pushdsilent pushdtohome pushdignoredups
    '';

    # Called whenever zsh is initialized
    initExtra = ''
      # Nix setup (environment variables, etc.)
      if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
      fi
      # Autocomplete for various utilities
      eval "$(lua ~/work/github.com/knl/rh/rh.lua --init zsh ~/work)"
      # Theme
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
      source ${sources.powerlevel10k}/powerlevel10k.zsh-theme

      # expands .... to ../..
      function expand-dot-to-parent-directory-path {
        if [[ $LBUFFER = *.. ]]; then
          LBUFFER+='/..'
        else
          LBUFFER+='.'
        fi
      }
      zle -N expand-dot-to-parent-directory-path

      bindkey -M emacs '\e[1;5D' backward-word
      bindkey -M emacs '\e[1;5C' forward-word
      bindkey -M emacs '\e[3~' delete-char
      bindkey -M emacs "^P" history-substring-search-up
      bindkey -M emacs "^N" history-substring-search-down
      # expand .... to ../..
      bindkey -M emacs "." expand-dot-to-parent-directory-path
      # but not during incremental search
      bindkey -M isearch . self-insert 2> /dev/null

      # more flexible push-line, C-q kills the line and restores after new line is executed
      for key in "\C-Q" "\e"{q,Q}
        bindkey -M emacs "$key" push-line-or-edit
      # Expand history on space.
      bindkey -M emacs ' ' magic-space

      # Execute code only if STDERR is bound to a TTY.
      if [[ -o INTERACTIVE && -t 2 ]]; then
        # Print a random, hopefully interesting, adage.
        if (( $+commands[fortune] )); then
          fortune -s
          print
        fi
      fi >&2

      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = sources.zsh-autosuggestions;
      }
      {
        name = "zsh-syntax-highlighting";
        src = sources.zsh-syntax-highlighting;
      }
      {
        name = "zsh-history-substring-search";
        src = sources.zsh-history-substring-search;
      }
      {
        name = "zsh-completions";
        src = sources.zsh-completions;
      }
      {
        name = "async";
        src = sources.zsh-async;
      }
      {
        # look at home.file.".p10k.zsh".source for config
        name = "powerlevel10k";
        src = sources.powerlevel10k;
      }
    ];
  };
  home.file.".p10k.zsh".source = ./p10k.zsh;

  # It's Hammerspoon time
  home.file.".hammerspoon/init.lua".source = ./hammerspoon/init.lua;
  home.file.".hammerspoon/grille.lua".source = "${sources.hs-grille}/grille.lua";
  home.file.".hammerspoon/winter.lua".source = "${sources.hs-winter}/winter.lua";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "21.03";
  };
}
