{ config, lib, pkgs, ... }:

let
  espanso_app =
    let
      app = "espanso.app";
      version = "2.3.0";
      src = pkgs.fetchzip {
        url = "https://github.com/espanso/espanso/releases/download/v${version}/Espanso-Mac-Universal.zip";
        hash = "sha256-aNH4qXVl1Yx52Eq5TT9MjfRlBCMHi5E6Rs/IYJMZ4yM=";
	stripRoot = false;
      };
    in
    pkgs.stdenvNoCC.mkDerivation rec {
      pname = "espanso";
      inherit version src;

      nativeBuildInputs = [ pkgs._7zz ];

      # Override how unpacking works
      unpackPhase = ''
        runHook preUnpack
        dmg=$(echo $src/espanso/*.dmg)
        7zz -snld x "$dmg"
        runHook postUnpack
      '';

      # sourceRoot = "source";

      postPatch = pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
        # substituteInPlace Espanso.app/Contents/Info.plist \
        #  --replace "<string>espanso</string>" "<string>${placeholder "out"}/Applications/Espanso.app/Contents/MacOS/espanso</string>"
        # substituteInPlace espanso/src/res/macos/com.federicoterzi.espanso.plist \
        #  --replace "<string>/Applications/Espanso.app/Contents/MacOS/espanso</string>" "<string>${placeholder "out"}/Applications/Espanso.app/Contents/MacOS/espanso</string>" \
        #  --replace "<string>/usr/bin" "<string>${placeholder "out"}/bin:/usr/bin"
      '';
      installPhase = ''
        mkdir -p "$out/Applications/Espanso.app"
        cp -R Espanso.app "$out/Applications/"

        mkdir -p "$out/bin"
        ln -s "$out/Applications/Espanso.app/Contents/MacOS/espanso" "$out/bin/espanso"
      '';

      meta = {
        description = "Cross-platform Text Expander written in Rust";
        homepage = "https://espanso.org";
        license = pkgs.lib.licenses.gpl3Plus;
        platforms = pkgs.lib.platforms.darwin;
        longDescription = ''
          Espanso detects when you type a keyword and replaces it while you're typing.
        '';
      };
    };
in
{
  config = {
    home.packages = [
      espanso_app
    ];
  };
}
