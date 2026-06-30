{ config, lib, ... }:
let
  sources = import ./npins/default.nix;
  pkgs = import sources.nixpkgs { };
  niv = import sources.niv { };
  link = config.lib.file.mkOutOfStoreSymlink;
  # Karabiner config rendered from the Nix attrset to JSON at build time.
  karabinerJson = pkgs.writeText "karabiner.json"
    (builtins.toJSON (import ./configs/karabiner/karabiner.nix));
  # Darwin specific run-or-raise style script for emacs.
  osascript = ''
    open $HOME/.nix-profile/Applications/Emacs.app
    command -v osascript > /dev/null 2>&1 && \
        osascript -e 'tell application "System Events" to tell process "Emacs"
        set frontmost to true
        windows where title contains "Emacs"
        if result is not {} then perform action "AXRaise" of item 1 of result
    end tell' &> /dev/null || exit 0'';

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

  theEmacs = pkgs.emacs30.pkgs.emacsWithPackages (epkgs: [
    # Native-module / native-artifact packages only; everything pure-elisp
    # is managed by Doom/straight. Runtime tools live in emacsRuntimeDeps and
    # reach Emacs via `doom env`.
    epkgs.treesit-grammars.with-all-grammars
    epkgs.melpaPackages.vterm
  ]);

  myAspell = pkgs.aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]);
  # Tools only Emacs needs. Not in home.packages; injected into the doom env
  # PATH snapshot by the doomEnv activation below. GC-safe: the store paths
  # are references of the generation's activation script.
  emacsRuntimeDeps = [
    myAspell
    pkgs.coreutils-prefixed # gls for dired (doom hardcodes "gls" on macOS)
    pkgs.editorconfig-core-c
    pkgs.gnutls
    pkgs.graphviz-nox # org-babel dot
  ];

  myFonts = with pkgs; [
    emacs-all-the-icons-fonts
    fira-code
    font-awesome
    # (iosevka.override { privateBuildPlan = { family = "Iosevka Term"; design = [ "term" "ss08" ]; }; set = "term-ss08"; })
    (iosevka-bin.override { variant = "SGr-IosevkaTermSS08"; })
    (iosevka-bin.override { variant = "Etoile"; })
    powerline-fonts
    powerline-symbols
    source-code-pro
  ] ++ pkgs.lib.attrValues (pkgs.lib.filterAttrs (_: v: pkgs.lib.isDerivation v) pkgs.nerd-fonts);


  programModules =
    let
      modulesDir = ./modules/programs;
    in
          map (name: modulesDir + "/${name}")
      (lib.filter (name: lib.hasSuffix ".nix" name)
        (lib.attrNames (builtins.readDir modulesDir)));

  # here goes everything that is not to be committed
  additionalProgramModules = [];

in
rec {
  imports = programModules ++ additionalProgramModules;

  # Allow non-free (as in beer) packages
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = false;
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
    (pkgs.callPackage ./nix/pkgs/ash.nix { })
    alejandra
    cachix
    curl
    devenv
    dua
    duf
    entr
    gnused
    gron
    hyperfine
    imagemagick
    jc
    jless
    lua
    moreutils
    mtr
    netcat
    niv.niv
    npins
    nixpkgs-fmt
    nix-output-monitor
    nmap
    openssh_hpnWithKerberos # needed because macOS version is limited wrt yubikey
    p7zip
    paperkey
    python3
    readline
    rsync
    scc
    sd
    shellcheck
    shfmt
    tokei
    tree
    unar
    viddy
    watch
    xz
    yq-go
    yubico-piv-tool
    yubikey-agent
    yubikey-manager
    yubikey-personalization
    zstd
    (pkgs.callPackage ./nix/pkgs/orgprotocolclient.nix { emacs = theEmacs; })
    # Use my own bespoke wrapper for `emacsclient`.
    (wrapEmacsclient { emacs = theEmacs; })
    # need to include the Emacs itself, as I'm avoiding programs.emacs because it makes doom unusable
    theEmacs
  ] ++ myFonts;

  programs.ghostty = {
    enable = true;
    package = pkgs.callPackage ./nix/pkgs/ghostty.nix { };
    enableZshIntegration = true;
  };

  programs.fzf.enable = true;
  # zsh init is generated at build time instead, see modules/programs/zsh.nix
  programs.fzf.enableZshIntegration = false;
  programs.carapace = {
    enable = true;
    # zsh init is generated at build time instead, see modules/programs/zsh.nix
    enableZshIntegration = false;
  };
  programs.eza = {
    enable = true;
    icons = "never";
    colors = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
    enableZshIntegration = true;
  };
  programs.htop = {
    enable = true;
    settings = {
      show_program_path = true;
      highlight_base_name = true;
      highlight_megabytes = true;
      detailed_cpu_time = true;
      cpu_count_from_one = true;
      show_cpu_frequency = true;
      hide_kernel_threads = true;
      delay = 15;
      color_scheme = 6;
      fields = with config.lib.htop.fields; [
        PID
        USER
        PRIORITY
        NICE
        M_SIZE
        M_RESIDENT
        STATE
        PERCENT_CPU
        PERCENT_MEM
        TIME
        COMM
      ];
    } // (with config.lib.htop; leftMeters [
      (bar "AllCPUs2")
      (bar "Memory")
      (bar "Swap")
    ]) // (with config.lib.htop; rightMeters [
      (text "Tasks")
      (text "LoadAverage")
      (text "Uptime")
    ]);
  };
  programs.jq = {
    enable = true;
    colors = {
      null       = "1;30";  # bold dark gray
      false      = "0;31";  # red
      true       = "0;32";  # green
      numbers    = "0;36";  # cyan
      strings    = "0;33";  # yellow
      arrays     = "1;35";  # bold magenta
      objects    = "1;37";  # bold white
      objectKeys = "1;34";  # bold blue
    };
  };
  programs.ripgrep = {
      enable = true; 
      arguments = [
      "--smart-case"
      "--hidden"
      "--glob=!.git"
      "--glob=!.jj"
      "--glob=!.svn"
      "--glob=!node_modules"
      "--glob=!.direnv"
      "--glob=!.devenv"
      "--glob=!.venv"
      "--max-columns=200"
      "--max-columns-preview"
    ];
  };
  programs.fd.enable = true;

  programs.uv = {
    enable = true;

    python = {
      versions = [ "3.14" "3.13" "3.12" ];
      default = [ "3.14" ];
      prune = true;
    };

    tool = {
      packages = [ "ruff" "prek" ];
      prune = true;
    };
  };

  # This creates a symlink to the file, so I can easily edit it
  # Not for the faint of heart, though...
  # TODO: maybe patch https://github.com/berbiche/dotfiles/blob/b5cb06db7764a963ab10b943d9269a51b12991e0/profiles/dev/home-manager/emacs/default.nix#L42
  home.file.".doom.d".source = link ./configs/doom;

  home.activation.installMyScripts = lib.hm.dag.entryAfter ["writeBoundary"] ''
    for script in ${./scripts}/{murder,notify,karabiner-nix}; do
      ln -sf "$script" "$HOME/bin/$(basename "$script")"
    done
  '';

  # Refresh doom's envvar snapshot so Emacs sees the tools from the new
  # generation. `doom env` records the doom CLI's own environment, so run it
  # inside a scrubbed interactive zsh: env -i drops the activation/nix-shell
  # pollution and the inherited guards (e.g. __HM_SESS_VARS_SOURCED) that
  # would suppress the PATH setup in zshenv, and zsh -ic then rebuilds the
  # same environment a fresh terminal would have. emacsRuntimeDeps are
  # prepended inside the -ic command (after zshenv/zshrc, so the session-vars
  # PATH= line can't clobber them) so they reach Emacs without polluting the
  # global profile.
  home.activation.doomEnv = lib.hm.dag.entryAfter ["installPackages"] ''
    if [ -x "$HOME/.emacs.d/bin/doom" ]; then
      run env -i HOME="$HOME" USER="$USER" SHELL=/bin/zsh TERM=dumb \
        PATH="$HOME/.nix-profile/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
        /bin/zsh -ic 'export PATH="${lib.makeBinPath emacsRuntimeDeps}:$PATH"; "$HOME/.emacs.d/bin/doom" env --force && "$HOME/.emacs.d/bin/doom" sync -u -e --aot --force' || run echo "doom env/sync failed"
    fi
  '';

  # programs.z-lua = {
  #   enable = true;
  #   options = [ "once" "fzf" ];
  # };
  programs.zoxide = {
    enable = true;
    # zsh init is generated at build time instead, see modules/programs/zsh.nix
    enableZshIntegration = false;
  };

  xdg.configFile."ghostty".source = link ./configs/ghostty;

  # Setting up aspell
  home.file.".aspell.conf".text = ''
    data-dir ${myAspell}/lib/aspell
    master en_US
    extra-dicts en-computers.rws
    add-extra-dicts en_US-science.rws
  '';

  # It's Hammerspoon time
  home.file.".hammerspoon/init.lua".source = ./configs/hammerspoon/init.lua;
  home.file.".hammerspoon/colemak.lua".source = ./configs/hammerspoon/colemak.lua;
  home.file.".hammerspoon/grille.lua".source = "${sources.hs-grille}/grille.lua";
  home.file.".hammerspoon/winter.lua".source = "${sources.hs-winter}/winter.lua";

  # Karabiner's config is defined as a Nix attrset (configs/karabiner/karabiner.nix,
  # the source of truth) and rendered to JSON at build time. Unlike the other
  # config files it is NOT a read-only store symlink: Karabiner-Elements must be
  # able to rewrite the file (GUI edits, its own normalisation), so we deploy a
  # writable copy via this activation gate. `karabiner-nix apply` aborts the
  # switch if the live file has GUI changes not yet reflected in karabiner.nix,
  # so they can't be silently clobbered; run `karabiner-nix import` to fold them
  # back in. See scripts/karabiner-nix.
  home.activation.karabiner = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    run ${pkgs.python3}/bin/python3 ${./scripts/karabiner-nix} apply \
      --generated ${karabinerJson} \
      --live "${config.xdg.configHome}/karabiner/karabiner.json" \
      --baseline "${config.xdg.stateHome}/karabiner-nix/baseline.json"
  '';

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
    stateVersion = "26.05";
  };
}
