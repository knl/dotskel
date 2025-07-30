{ config, lib, pkgs, ... }:

let
  espanso_app =
    let
      app = "espanso.app";
      version = "2.2.1";
      sources = {
        darwin-x86_64 = pkgs.fetchzip {
          url = "https://github.com/federico-terzi/espanso/releases/download/v${version}/Espanso-Mac-Intel.zip";
          hash = "sha256-lVO8Vwn7WIMIuLP1bKdG9fmsp6ll9JwzfiSGXMI9MR1=";
        };
        darwin-aarch64 = pkgs.fetchzip {
          url = "https://github.com/federico-terzi/espanso/releases/download/v${version}/Espanso-Mac-M1.zip";
          hash = "sha256-L4jEGJw1CIH7sXIh79oovlQnDG+RHEKjglmeGQUx398=";
        };
      };
    in
    pkgs.stdenvNoCC.mkDerivation rec {
      pname = "espanso";
      inherit version;

      src = if pkgs.stdenv.isAarch64 then sources.darwin-aarch64 else sources.darwin-x86_64;

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
        cp -R . "$out/Applications/Espanso.app"

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
