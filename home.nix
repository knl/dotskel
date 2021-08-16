{ config, pkgs, ... }:
let
  sources = import ./nix/sources.nix;
  overlays = let path = ./nix/overlays; in
    with builtins;
    map (n: import (path + ("/" + n)))
      (filter
        (n: match ".*\\.nix" n != null ||
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
    dataHome = "${home.homeDirectory}/.local/share";
    cacheHome = "${home.homeDirectory}/.cache";
  };

  # Packages in alphabetical order, as I can't do categories
  home.packages = with pkgs; [
    aspell # needed for emacs
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    bat
    duf
    exa
    fd
    fortune
    gitAndTools.gitFull
    gitAndTools.hub
    glances
    gnused
    htop
    hyperfine
    imagemagick
    jq
    loc
    lua
    mcfly
    moreutils
    mtr
    ncdu
    netcat
    niv
    nmap
    p7zip
    paperkey
    procs
    python3
    python3Packages.tvnamer
    readline
    ripgrep
    rsync
    sd
    shellcheck
    shfmt
    tree
    unar
    xz
    yq-go
    watch
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
    nix-direnv.enable = true;
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
  home.file.".spacemacs".source = link ./configs/spacemacs;

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
  home.file.".gitaliases".source = ./configs/gitaliases;

  programs.z-lua = {
    enable = true;
    options = [ "once" "fzf" ];
  };

  programs.zsh = rec {
    enable = true;

    # This way, my functions could be stored under
    # .config/zsh/lib
    dotDir = ".config/zsh";

    enableAutosuggestions = true;
    enableCompletion = true;
    history = {
      size = 50000;
      save = 500000;
      # Put the ZSH history into the same directory as the configuration.
      # Also, the path must be absolute, relative paths just make new directories
      # wherever you're working from.
      path = let
        inherit (config.home) homeDirectory;
        in "${homeDirectory}/${dotDir}/history";
      extended = true;
      ignoreDups = true;
      share = true;
    };

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
      zb = "z -b";
      zh = "z -I -t .";
      # fd's default of not searching hidden files is annoying
      f = "fd -H --no-ignore";

      # commonly used git aliases (lifted from prezto)
      g = "git";
      ga = "git add";
      gai = "git add -i";
      gap = "git add --patch";
      gau = "git add --update";
      gb = "git branch";
      gbx = "git branch -d";
      gbX = "git branch -D";
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
      gup = ''git fetch -p && git rebase --autostash "''${$(git symbolic-ref refs/remotes/origin/HEAD)#refs/remotes/}"'';
      gfa = "git fetch --all -v";
      stash = "git stash";
      unstash = "git stash pop";
      staged = "git diff --no-ext-diff --cached";
    };

    initExtraFirst = ''
      DIRSTACKSIZE=10

      setopt   notify globdots correct cdablevars autolist
      setopt   correctall autocd recexact longlistjobs
      setopt   autoresume
      setopt   rcquotes mailwarning
      unsetopt bgnice
      setopt   autopushd pushdminus pushdsilent pushdtohome pushdignoredups

      setopt COMPLETE_IN_WORD    # Complete from both ends of a word.
      setopt ALWAYS_TO_END       # Move cursor to the end of a completed word.
      setopt AUTO_MENU           # Show completion menu on a successive tab press.
      setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
      setopt EXTENDED_GLOB       # Needed for file modification glob modifiers with compinit
      unsetopt AUTO_PARAM_SLASH    # If completed parameter is a directory, do not add a trailing slash.
      unsetopt MENU_COMPLETE     # Do not autoselect the first completion entry.
      unsetopt FLOW_CONTROL      # Disable start/stop characters in shell editor.
    '';

    # Called whenever zsh is initialized
    initExtra = ''
      # Nix setup (environment variables, etc.)
      if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
      fi
      # Autocomplete for various utilities
      eval "$(lua ${sources.rh}/rh.lua --init zsh ~/work)"

      # Completion settings
      source ${config.xdg.configHome}/zsh/completion.zsh

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

      fpath=(${config.xdg.configHome}/zsh/functions(-/FN) $fpath)
      # functions must be autoloaded, do it in a function to isolate
      function {
        local pfunction_glob='^([_.]*|prompt_*_setup|README*|*~)(-.N:t)'

        local pfunction
        # Extended globbing is needed for listing autoloadable function directories.
        setopt LOCAL_OPTIONS EXTENDED_GLOB

        for pfunction in ${config.xdg.configHome}/zsh/functions/$~pfunction_glob; do
          autoload -Uz "$pfunction"
        done
      }

      # Theme (custom built on powerlevel10k)
      # First load all variables
      source ${config.xdg.configHome}/zsh/p10k.zsh
      # Then source the theme
      source ${sources.powerlevel10k}/powerlevel10k.zsh-theme
    '';

    loginExtra = ''
      # Execute code only if STDERR is bound to a TTY.
      if [[ -o INTERACTIVE && -t 2 ]]; then
        # Print a random, hopefully interesting, adage.
        if (( $+commands[fortune] )); then
          fortune -s
          print
        fi
      fi >&2
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
      {
        name = "zsh-you-should-use";
        src = sources.zsh-you-should-use;
      }
    ];
  };
  xdg.configFile."zsh/p10k.zsh".source = ./zsh/p10k.zsh;
  xdg.configFile."zsh/functions".source = ./zsh/functions;
  xdg.configFile."zsh/completion.zsh".source = ./zsh/completion.zsh;


  # Setting up aspell
  home.file.".aspell.conf".text = ''
     data-dir ${builtins.getEnv "HOME"}/.nix-profile/lib/aspell
     master en_US
     extra-dicts en-computers.rws
     add-extra-dicts en_US-science.rws
  '';

  # It's Hammerspoon time
  home.file.".hammerspoon/init.lua".source = ./configs/hammerspoon/init.lua;
  home.file.".hammerspoon/grille.lua".source = "${sources.hs-grille}/grille.lua";
  home.file.".hammerspoon/winter.lua".source = "${sources.hs-winter}/winter.lua";

  # Karabiner's config file
  xdg.configFile."karabiner/karabiner.json".source = ./configs/karabiner/karabiner.json;

  # iTerm2 settings
  # Use link here, so when something changes, it gets propagated back
  xdg.configFile."iterm2/com.googlecode.iterm2.plist".source = link ./preferences/com.googlecode.iterm2.plist;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  targets.darwin.defaults = {
    "com.apple.desktopservices" = {
      # Avoid creating .DS_Store files on network volumes (default: false).
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.dock" = {
      # hide and put it on right
      autohide = true;
      orientation = "right";
      # Don’t automatically rearrange Spaces based on most recent use
      "mru-spaces" = 0;
      # Don’t show Dashboard as a Space
      "dashboard-in-overlay" = true;
      # Make it small
      tilesize = 42;
    };
    # Disable Dashboard
    "com.apple.dashboard" = {
      "mcx-disabled" = true;
    };
    "Apple Global Domain" = {
      # Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs) (default: not set).
      AppleKeyboardUIMode = 3;
      # Always show scrollbars (default: WhenScrolling).
      AppleShowScrollBars = "Always";
      # Show all filename extensions in Finder (default: false).
      AppleShowAllExtensions = true;
      # Expand save panel (default: false).
      NSNavPanelExpandedStateForSaveMode = true;
      # Display ASCII control characters using caret notation in standard text views
      # Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
      NSTextShowsControlCharacters = true;
      # Disable smart quotes as they’re annoying when typing code
      NSAutomaticQuoteSubstitutionEnabled = false;
      # Disable smart dashes as they’re annoying when typing code
      NSAutomaticDashSubstitutionEnabled = false;
      # Disable automatic capitalization as it’s annoying when typing code
      NSAutomaticCapitalizationEnabled = false;
      # Disable automatic period substitution as it’s annoying when typing code
      NSAutomaticPeriodSubstitutionEnabled = false;
      # Disable auto-correct
      NSAutomaticSpellingCorrectionEnabled = false;
      # Disable “natural” (Lion-style) scrolling
      "com.apple.swipescrolldirection" = false;
      # Trackpad: enable tap to click for this user
      "com.apple.mouse.tapBehavior" = 1;
      # Trackpad: map tap with two fingers to secondary click
      "com.apple.trackpad.trackpadCornerClickBehavior" = 1;
      "com.apple.trackpad.enableSecondaryClick" = true;
      # Set language and text formats
      AppleLanguages = [ "en" ];
      AppleLocale = "en_CH";
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = true;
    };
    "com.apple.finder" = {
      # Display full POSIX path as Finder window title (default: false).
      _FXShowPosixPathInTitle = true;
      # Disable the warning when changing a file extension (default: true).
      FXEnableExtensionChangeWarning = false;
      # Show hidden files by default
      AppleShowAllFiles = true;
      # Show status bar
      ShowStatusBar = true;
      # Show path bar
      ShowPathbar = true;
      # Allow text selection in Quick Look
      QLEnableTextSelection = true;
    };
    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
      # Trackpad: enable tap to click for this user
      Clicking = true;
      # Trackpad: map tap with two fingers to secondary click
      TrackpadCornerSecondaryClick = 1;
      TrackpadRightClick = true;
    };
    "com.apple.HIToolbox" = {
      AppleCurrentKeyboardLayoutInputSourceID = "com.apple.keylayout.ABC";
      AppleEnabledInputSources = [
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 252;
          "KeyboardLayout Name" = "ABC";
        }
        {
          "Bundle ID" = "com.apple.inputmethod.EmojiFunctionRowItem";
          InputSourceKind = "Non Keyboard Input Method";
        }
        {
          "Bundle ID" = "com.apple.PressAndHold";
          InputSourceKind = "Non Keyboard Input Method";
        }
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 19;
          "KeyboardLayout Name" = "Swiss German";
        }
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 19521;
          "KeyboardLayout Name" = "Serbian";
        }
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = -19521;
          "KeyboardLayout Name" = "Serbian-Latin";
        }
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = -1;
          "KeyboardLayout Name" = "Unicode Hex Input";
        }
      ];
      AppleSelectedInputSources = [
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 252;
          "KeyboardLayout Name" = "ABC";
        }
        {
          "Bundle ID" = "com.apple.inputmethod.EmojiFunctionRowItem";
          InputSourceKind = "Non Keyboard Input Method";
        }
        {
          "Bundle ID" = "com.apple.PressAndHold";
          InputSourceKind = "Non Keyboard Input Method";
        }
      ];
    };
  };

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
