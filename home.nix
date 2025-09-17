{ config, lib, ... }:
let
  sources = import ./npins/default.nix;
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
      pkgs' = pkgs.extend (
        _final: prev: {
          ld64 = prev.ld64.overrideAttrs (old: {
            patches = old.patches or [ ] ++ [ ./Dedupe-RPATH-entries.patch ];
          });
        }
      );
      emacsSource_ = pkgs'.emacs30.override { withNativeCompilation = true; };
      emacsSource = pkgs.emacs30;
      emacsSource1 = pkgs.emacs30.overrideAttrs (old: {
        #        patches =
        #          (old.patches or [])
        #          ++ [
        #            # Fix OS window role (needed for window managers like yabai)
        #            (pkgs.fetchpatch {
        #              url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
        #              sha256 = "sha256-+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
        #            })
        #            # Enable rounded window with no decoration
        #            (pkgs.fetchpatch {
        #              url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-29/round-undecorated-frame.patch";
        #              sha256 = "sha256-uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
        #            })
        #            # Make Emacs aware of OS-level light/dark mode
        #            # points to emacs-28, as 29 is just a symlink
        #            (pkgs.fetchpatch {
        #              url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/system-appearance.patch";
        #              sha256 = "sha256-oM6fXdXCWVcBnNrzXmF0ZMdp8j0pzkLE66WteeCutv8=";
        #            })
        #          ];
        postPatch = old.postPatch + ''
          # copy the nice icon to it
          cp ${spacemacsIcon} mac/Emacs.app/Contents/Resources/Emacs.icns
        '';
      });
      emacsPkg = emacsSource.pkgs.emacsWithPackages (epkgs: with epkgs; [
        treesit-grammars.with-all-grammars
        nerd-icons
      ] ++ (with epkgs.melpaPackages; [
        vterm
        all-the-icons
        emojify
      ]));
      deps = [
        (pkgs.aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
        (pkgs.hunspellWithDicts (with pkgs.hunspellDicts; [ en_GB-large ]))
        (pkgs.nuspellWithDicts (with pkgs.hunspellDicts; [ en_GB-large ]))
        pkgs.graphviz-nox
        pkgs.imagemagick # for image-dired
        pkgs.gnutls # for TLS connectivity
        pkgs.coreutils # needed for gls for dired
        pkgs.binutils # native-comp needs 'as', provided by this
        # :tools editorconfig
        pkgs.editorconfig-core-c
        # :tools lookup & :lang org +roam
        pkgs.sqlite
      ];
    in
    emacsPkg;

  myFonts = with pkgs; [
    emacs-all-the-icons-fonts
    emacsPackages.nerd-icons
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
      allowUnsupportedSystem = true;
      permittedInsecurePackages = [
        "my-doom-emacs"
        "emacs-mac-macport-with-packages-29.1"
        "emacs-mac-macport-29.1"
        "emacs-29.4"
      ];
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
    devenv
    dua
    duf
    entr
    eza
    fd
    fortune
    gnused
    gron
    htop
    hyperfine
    imagemagick
    jc
    jless
    jq
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
    ripgrep
    rsync
    scc
    sd
    shellcheck
    shfmt
    tokei
    tree
    unar
    uv
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

  # programs.emacs = {
  #   enable = true;
  #   package = theEmacs;
  #   # extraPackages = (epkgs: [epkgs.pdf-tools] );
  # };
  programs.fzf.enable = true;
  programs.carapace = {
    enable = true;
    enableZshIntegration = true;
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


  programs.z-lua = {
    enable = true;
    options = [ "once" "fzf" ];
  };

  xdg.configFile."ghostty".source = link ./configs/ghostty;

  # Setting up aspell
  home.file.".aspell.conf".text = ''
    data-dir ${builtins.getEnv "HOME"}/.nix-profile/lib/aspell
    master en_US
    extra-dicts en-computers.rws
    add-extra-dicts en_US-science.rws
  '';

  # It's Hammerspoon time
  home.file.".hammerspoon/init.lua".source = ./configs/hammerspoon/init.lua;
  home.file.".hammerspoon/colemak.lua".source = ./configs/hammerspoon/colemak.lua;
  home.file.".hammerspoon/grille.lua".source = "${sources.hs-grille}/grille.lua";
  home.file.".hammerspoon/winter.lua".source = "${sources.hs-winter}/winter.lua";

  # Karabiner's config file
  xdg.configFile."karabiner/karabiner.json".source = link ./configs/karabiner/karabiner.json;

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
    stateVersion = "23.05";
  };
}
