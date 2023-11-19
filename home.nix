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
      # temporarily disable as I'm trying out #doom
      # (import sources.emacs-overlay)
    ] ++ overlays;
  };
  devenv = import sources.devenv;
  niv = import sources.niv { };
  link = config.lib.file.mkOutOfStoreSymlink;
  # Darwin specific run-or-raise style script for emacs.
  osascript = ''
    open $HOME/.nix-profile/Applications/Emacs.app
    command -v osascript > /dev/null 2>&1 && \
        osascript -e 'tell application "System Events" to tell process "Emacs"
        set frontmost to true
        windows where title contains "Emacs"
        if result is not {} then perform action "AXRaise" of item 1 of result
    end tell' &> /dev/null || exit 0'';

  python3Custom = pkgs.python3.buildEnv.override {
    extraLibs = with pkgs.python3Packages; [ ipython pip virtualenv ];
  };

  wezterm_app = let
    app = "WezTerm.app";
    version = "20230712-072601-f4abf8fd";
    altIcon = pkgs.fetchurl {
      url = "https://github.com/mikker/wezterm-icon/raw/main/wezterm.icns";
      hash = "sha256-svfuxXlRmFW+9n40LBm3JygzLbp90C4LAnCQAr4XFDw=";
    };
  in
  pkgs.stdenv.mkDerivation rec {
    pname = "wezterm";
    inherit version;

    src = pkgs.fetchzip {
      url = "https://github.com/wez/wezterm/releases/download/${version}/WezTerm-macos-${version}.zip";
      sha256 = "sha256-8PHHTVjcFDQ0Ic1UpUnMoYtSlxL1e/15zo5Jk9Sqb5E=";
    };

    buildInputs = [ pkgs.undmg ];
    installPhase = ''
      mkdir -p "$out/Applications/"
      cp -R . "$out/Applications/"
      cp ${altIcon} $out/Applications/WezTerm.app/Contents/Resources/terminal.icns
    '';

    meta = {
      description = "A GPU-accelerated cross-platform terminal emulator and multiplexer written by @wez and implemented in Rust";
      homepage = "https://wezfurlong.org/wezterm";
      changelog = "https://wezfurlong.org/wezterm/changelog.html#${version}";
      license = pkgs.lib.licenses.mit;
      platforms = pkgs.lib.platforms.darwin;
    };
  };

  wrapEmacsclient = { emacs }:
    pkgs.writeShellScriptBin "emacs.bash" (''
      ${emacs}/bin/emacsclient --no-wait --eval \
        "(if (> (length (frame-list)) 0) 't)" 2> /dev/null | grep -q t
        if [[ "$?" -eq 1 ]]; then
          ${emacs}/bin/emacsclient \
            --quiet --create-frame --alternate-editor="" "$@"
        else
          ${emacs}/bin/emacsclient --quiet "$@"
        fi
    ''
    + pkgs.lib.optionalString pkgs.stdenv.isDarwin osascript)
  ;

  theEmacs =
    let
      spacemacsIcon = pkgs.fetchurl {
        url = "https://github.com/nashamri/spacemacs-logo/raw/917f2f2694019d534098f5e2e365b5f6e5ddbd37/spacemacs.icns";
        sha256 = "sha256:0049lkmc8pmb9schjk5mqy372b3m7gg1xp649gibriabz9y8pnxk";
      };
      emacsSource = pkgs.emacs29-macport.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            # Fix OS window role (needed for window managers like yabai)
            (pkgs.fetchpatch {
              url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
              sha256 = "sha256-+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
            })
            # Use poll instead of select to get file descriptors
            (pkgs.fetchpatch {
              url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-29/poll.patch";
              sha256 = "sha256-jN9MlD8/ZrnLuP2/HUXXEVVd6A+aRZNYFdZF8ReJGfY=";
            })
            # Enable rounded window with no decoration
            (pkgs.fetchpatch {
              url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-29/round-undecorated-frame.patch";
              sha256 = "sha256-uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
            })
            # Make Emacs aware of OS-level light/dark mode
            # points to emacs-28, as 29 is just a symlink
            (pkgs.fetchpatch {
              url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/system-appearance.patch";
              sha256 = "sha256-oM6fXdXCWVcBnNrzXmF0ZMdp8j0pzkLE66WteeCutv8=";
            })
          ];
        postPatch = old.postPatch + ''
          # copy the nice icon to it
          cp ${spacemacsIcon} mac/Emacs.app/Contents/Resources/Emacs.icns
        '';
      });
      emacsPkg = emacsSource.pkgs.emacsWithPackages (epkgs: with epkgs; [
        treesit-grammars.with-all-grammars
      ] ++ (with epkgs.melpaPackages; [
        vterm
        all-the-icons
      ]));
      deps = [
        (pkgs.aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
        (pkgs.hunspellWithDicts (with pkgs.hunspellDicts; [ en_GB-large ]))
        (pkgs.nuspellWithDicts (with pkgs.hunspellDicts; [ en_GB-large ]))
        pkgs.graphviz-nox
        pkgs.imagemagick # for image-dired
        pkgs.fd
        pkgs.gnutls # for TLS connectivity
        pkgs.coreutils # needed for gls for dired
        pkgs.binutils # native-comp needs 'as', provided by this
        (pkgs.ripgrep.override { withPCRE2 = true; })
        pkgs.zstd
        pkgs.git
        # :tools editorconfig
        pkgs.editorconfig-core-c
        # :tools lookup & :lang org +roam
        pkgs.sqlite
        # other goodies
        pkgs.alejandra # to format nix code
        pkgs.shfmt
        pkgs.jq
      ];
      env = ''
        (setq exec-path (append exec-path '( ${pkgs.lib.concatMapStringsSep " " (x: ''"${x}/bin"'') deps} )))
      '';
    in
    (pkgs.symlinkJoin {
      name = "my-doom-emacs";
      paths = [ emacsPkg ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/emacs \
          --prefix PATH : ${pkgs.lib.makeBinPath deps}:${config.home.homeDirectory}/.emacs.d/bin \
          --set LSP_USE_PLISTS true
        wrapProgram $out/bin/emacsclient \
          --prefix PATH : ${pkgs.lib.makeBinPath deps}:${config.home.homeDirectory}/.emacs.d/bin \
          --set LSP_USE_PLISTS true
      ''
      + (pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
        wrapProgram $out/Applications/Emacs.app/Contents/MacOS/Emacs \
          --prefix PATH : ${pkgs.lib.makeBinPath deps}:${config.home.homeDirectory}/.emacs.d/bin \
          --set LSP_USE_PLISTS true
      '');
      inherit (pkgs.emacs29-macport) meta;
    });

  myFonts = with pkgs; [
    emacs-all-the-icons-fonts
    fira-code
    font-awesome
    # (iosevka.override { privateBuildPlan = { family = "Iosevka Term"; design = [ "term" "ss08" ]; }; set = "term-ss08"; })
    (iosevka-bin.override { variant = "sgr-iosevka-term-ss08"; })
    (iosevka-bin.override { variant = "etoile"; })
    powerline-fonts
    powerline-symbols
    source-code-pro
  ];
in
rec {
  # Allow non-free (as in beer) packages
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
  };

  # fix for https://github.com/nix-community/home-manager/issues/3344
  manual.manpages.enable = false;

  xdg = {
    enable = true;

    configHome = "${home.homeDirectory}/.config";
    dataHome = "${home.homeDirectory}/.local/share";
    cacheHome = "${home.homeDirectory}/.cache";
  };

  # Packages in alphabetical order, as I can't do categories
  home.packages = with pkgs; [
    alejandra
    cachix
    curl
    devenv.default
    dua
    duf
    entr
    espanso # FIXME: make it compilable on macos
    eza
    fd
    fortune
    gitAndTools.delta
    gitAndTools.git-branchless
    gitAndTools.gitSVN
    gitAndTools.hub
    gnused
    gron
    htop
    hyperfine
    imagemagick
    jc
    jless
    jq
    loc
    lua
    moreutils
    mtr
    netcat
    niv.niv
    nixpkgs-fmt
    nmap
    openssh # needed because macOS version is limited wrt yubikey
    p7zip
    paperkey
    python3Custom
    readline
    ripgrep
    rsync
    sd
    shellcheck
    shfmt
    tree
    unar
    # problems with fastparquet, hence the override
    # problems with building skia-pathops (dep of fonttools, dep of visidata), hence comment out
    # (visidata.overrideAttrs (old: rec {
    #  propagatedBuildInputs = old.propagatedBuildInputs ++ [ python3Packages.pyarrow python3Packages.fastparquet ];
    # }))
    xz
    yq-go
    yubico-piv-tool
    yubikey-agent
    yubikey-manager
    yubikey-personalization
    watch
    zstd
    (pkgs.callPackage ./nix/pkgs/orgprotocolclient.nix { emacs = theEmacs; })
    # Use my own bespoke wrapper for `emacsclient`.
    (wrapEmacsclient { emacs = theEmacs; })
    # need to include the Emacs itself, as I'm avoiding programs.emacs because it makes doom unusable
    theEmacs
  ] ++ myFonts;

  # TODO:
  # Install the following apps (might need nix-darwin)
  # hammerspoon
  # karabiner
  # istatmenus
  # trello
  # busycall

  # programs.emacs = {
  #   enable = true;
  #   package = theEmacs;
  #   # extraPackages = (epkgs: [epkgs.pdf-tools] );
  # };
  programs.wezterm = {
    enable = true;
    package = wezterm_app;
    # this doesn't work, as my wezterm comes from the official distribution
    enableZshIntegration = false;
    enableBashIntegration = false;
  };
  xdg.configFile."wezterm".source = link ./configs/wezterm;

  programs.fzf.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.bat = {
    enable = true;
    config = {
      style = "header,changes";
      theme = "Monokai Extended";
    };
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

  # home.file.".emacs.d" = {
  #   source = link sources.doomemacs;
  #   recursive = true;
  #   onChange = "${config.home.homeDirectory}/.emacs.d/bin/doom sync";
  # };

  # This creates a symlink to the file, so I can easily edit it
  # Not for the faint of heart, though...
  # TODO: maybe patch https://github.com/berbiche/dotfiles/blob/b5cb06db7764a963ab10b943d9269a51b12991e0/profiles/dev/home-manager/emacs/default.nix#L42
  home.file.".doom.d".source = link ./configs/doom;

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
      rebase = {
        autoSquash = true;
        autoStash = true;
      };
      rerere = {
        autoupdate = true;
        enabled = true;
      };
      # Sort tags as version numbers whenever applicable, so 1.10.2 is AFTER 1.2.0.
      tag.sort = "version:refname";
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
      path =
        let
          inherit (config.home) homeDirectory;
        in
        "${homeDirectory}/${dotDir}/history";
      extended = true;
      ignoreDups = true;
      share = true;
    };

    sessionVariables = rec {
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";

      NVIM_TUI_ENABLE_TRUE_COLOR = "1";

      BROWSER = if pkgs.stdenv.isDarwin then "open" else "xdg-open";

      # use the same nixpkgs for the rest of the system as we use here
      NIX_PATH = "nixpkgs=${sources.nixpkgs}:home-manager=${sources."home-manager"}";

      EDITOR = "vim";
      VISUAL = EDITOR;
      GIT_EDITOR = EDITOR;

      XDG_CONFIG_HOME = xdg.configHome;
      XDG_CACHE_HOME = xdg.cacheHome;
      XDG_DATA_HOME = xdg.dataHome;

      GOPATH = "$HOME/go";
      PATH = "$HOME/bin:$GOPATH/bin:$HOME/.emacs.d/bin:${wezterm_app}/Applications/WezTerm.app/Contents/MacOS/:$PATH";
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
      l = "eza --color auto";
      ls = "eza -G --color auto -a -s type";
      ll = "eza -l --color always -a -s type";
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
      k = "kubectl";
      hm = "home-manager";
      d = "direnv";

      df = "duf";
      du = "dua";

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

      setopt   emacs

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

      # Completion settings
      source ${config.xdg.configHome}/zsh/completion.zsh

      fpath=(${config.xdg.configHome}/zsh/plugins/zsh-completions/src \
             ${config.xdg.configHome}/zsh/vendor-completions \
             ${config.xdg.configHome}/zsh/plugins/mac-zsh-completions/completions \
             $fpath)

      # compinit will be called after this block
    '';

    # Called whenever zsh is initialized
    initExtra = ''
      # Nix setup (environment variables, etc.)
      if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
      fi

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
      # also bind to keys up and down
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
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

      eval "$(lua ${sources.rh}/rh.lua --init zsh ~/work)"

      # Theme (custom built on powerlevel10k)
      # First load all variables
      source ${config.xdg.configHome}/zsh/p10k.zsh
      # Then source the theme
      source ${sources.powerlevel10k}/powerlevel10k.zsh-theme

      # zsh-histdb start
      HISTDB_TABULATE_CMD=(sed -e $'s/\x1f/\t/g')

      source ''${ZDOTDIR}/plugins/zsh-histdb/sqlite-history.zsh

      _zsh_autosuggest_strategy_histdb_top() {
          local query="
              select commands.argv from history
              left join commands on history.command_id = commands.rowid
              left join places on history.place_id = places.rowid
              where commands.argv LIKE '$(sql_escape $1)%'
              group by commands.argv, places.dir
              order by places.dir != '$(sql_escape $PWD)', count(*) desc
              limit 1
          "
          suggestion=$(_histdb_query "$query")
      }

      ZSH_AUTOSUGGEST_STRATEGY=histdb_top

      # need to rebind the key again, since plugins are sourced before sourcing fzf
      bindkey '^R' histdb-fzf-widget
      # zsh-histdb end

      # wezterm integration
      source "${wezterm_app}/Applications/WezTerm.app/Contents/Resources/wezterm.sh"
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
        name = "fast-syntax-highlighting";
        src = sources.fast-syntax-highlighting;
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
        name = "nix-zsh-completions";
        src = sources.nix-zsh-completions;
      }
      {
        name = "mac-zsh-completions";
        src = sources.mac-zsh-completions;
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
      {
        name = "zsh-histdb";
        src = sources.zsh-histdb;
      }
      {
        name = "zsh-histdb-fzf";
        src = sources.zsh-histdb-fzf;
      }
    ];
  };
  xdg.configFile."zsh/p10k.zsh".source = ./zsh/p10k.zsh;
  xdg.configFile."zsh/functions".source = ./zsh/functions;
  xdg.configFile."zsh/completion.zsh".source = ./zsh/completion.zsh;
  xdg.configFile."zsh/vendor-completions".source = with pkgs;
    runCommand "vendored-zsh-completions" { } ''
      set -euo pipefail
      mkdir -p $out
      ${fd}/bin/fd -t f '^_[^.]+$' \
        ${lib.escapeShellArgs home.packages} \
        | xargs -0 -I {} bash -c '${ripgrep}/bin/rg -0l "^#compdef" $@ || :' _ {} \
        | xargs -0 cp -t $out/
    '';

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
  xdg.configFile."karabiner/karabiner.json".source = link ./configs/karabiner/karabiner.json;

  # iTerm2 settings
  # Use link here, so when something changes, it gets propagated back
  xdg.configFile."iterm2/com.googlecode.iterm2.plist".source = link ./preferences/com.googlecode.iterm2.plist;

  # Use cachix to speed up some fetches (niv, specifically)
  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
    keep-outputs = true
    keep-derivations = true
    substituters = https://knl.cachix.org https://niv.cachix.org https://cache.nixos.org https://nix-community.cachix.org https://fzakaria.cachix.org https://devenv.cachix.org
    trusted-public-keys = knl.cachix.org-1:/iqUbqBexzvcDn5ee7Q3Kj1MBh6P9RTwEVh6hh9SDE0= niv.cachix.org-1:X32PCg2e/zAm3/uD1ScqW2z/K0LtDyNV7RdaxIuLgQM= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= fzakaria.cachix.org-1:SpQviPuoJ3GnCVG40vwTp/r9y1/cbwP808SbMJ/XlGo= devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
  '';

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
    stateVersion = "23.05";
  };
}
