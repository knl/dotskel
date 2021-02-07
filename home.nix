{ config, pkgs, ... }:

let
  sources = import ./nix/sources.nix;
  overlays = let path = ./overlays; in with builtins;
    map (n: import (path + ("/" + n)))
      (filter (n: match ".*\\.nix" n != null ||
                  pathExists (path + ("/" + n + "/default.nix")))
        (attrNames (readDir path)));
  pkgs = import sources.nixpkgs {
    # Get all files in overlays
    overlays = [
       (_self: super: { inherit sources; })
    ] ++ overlays;
  };
  link = config.lib.file.mkOutOfStoreSymlink;
in
rec {
  # Allow non-free (as in beer) packages
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
  };

  xdg = {
    enable = true;

    configHome = "${home.homeDirectory}/.config";
    dataHome   = "${home.homeDirectory}/.local/share";
    cacheHome  = "${home.homeDirectory}/.cache";
  };

  # Packages in alphabetical order, as I can't do categories
  home.packages = with pkgs; [
    bat
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
    unar
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

    # This way, my functions could be stored under
    # .config/zsh/lib
    dotDir = ".config/zsh";

    enableAutosuggestions = true;
    enableCompletion = true;
    history.extended = true;

    sessionVariables = rec {
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";

      NVIM_TUI_ENABLE_TRUE_COLOR = "1";

      BROWSER = if pkgs.stdenv.isDarwin then "open" else "xdg-open";

      EDITOR = "vim";
      VISUAL = EDITOR;
      GIT_EDITOR = EDITOR;

      XDG_CONFIG_HOME = xdg.configHome;
      XDG_CACHE_HOME = xdg.cacheHome;
      XDG_DATA_HOME = xdg.dataHome;

      GOPATH = "$HOME/go";
      PATH = "$HOME/bin:$GOPATH/bin:$PATH";
      TERM = "xterm-256color";

      LESS = "-F -g -i -M -R -S -w -X -z-4";

      # This is to make `z my-dir` work with z.lua
      _ZL_HYPHEN = "1";
    };

    localVariables = {
      # This way, C-w deletes words (path elements)
      WORDCHARS = "*?_-.[]~&;!#$%^(){}<>";

      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=8";
    };

    shellAliases = {
      l = "exa --color auto";
      ls = "exa -G --color auto -a -s type";
      ll = "exa -l --color always -a -s type";
      "]" = "open";
      dl = "\curl -O -L";
      up = "\cd ..";
      p = "pushd";
      pd = "perldoc";
      mkdir = "nocorrect mkdir";
      cat = "bat";
      x = "unar";

      # commonly used git aliases (lifted from prezto)
      g = "git";
      ga = "git add";
      gai = "git add -i";
      gap = "git add --patch";
      gau = "git add --update";
      gb = "git branch";
      gbx = "git branch -x";
      gbX = "git branch -X";
      gba = "git branch -a";
      gbm = "git branch -m";
      gc = "git commit --verbose";
      gcm = "git commit --message";
      gcf = "git commit --amend --reuse-message HEAD";
      gco = "git checkout";
      gd = "git diff";
      gl = "git pull";
      gm = "git merge";
      gma = "git merge --abort";
      gcpa = "git cherry-pick --abort";
      gp = "git push -u";
      gpf = "git push -u --force-with-lease";
      gpa = "git push --all && git push --tags";
      gr = "git rebase";
      gri = "git rebase --interactive";
      gra = "git rebase --abort";
      grc = "git rebase --continue";
      grs = "git rebase --skip";
      gst = "git status";
      gt = "git tag";
      gup = "git fetch -p && git rebase --autostash origin/master";
      stash = "git stash";
      unstash = "git stash pop";
      staged = "git diff --no-ext-diff --cached";
    };

    # initExtraBeforeCompInit?
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

  # Karabiner's config file
  xdg.configFile."karabiner/karabiner.json".source = ./karabiner/karabiner.json;

  # iTerm2 settings
  # Use link here, so when something changes, it gets propagated back
  xdg.configFile."iterm2/com.googlecode.iterm2.plist".source = link ./preferences/com.googlecode.iterm2.plist;

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
