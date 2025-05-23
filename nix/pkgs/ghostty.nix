{
  stdenv,
  lib,
  _7zz,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "ghostty";
  version = "1.1.3";

  src = fetchurl {
    name = "${pname}-${version}.dmg";
    url = "https://release.files.ghostty.org/${version}/Ghostty.dmg";
    hash = "sha256-ZOUUGI9UlZjxZtbctvjfKfMz6VTigXKikB6piKFPJkc=";
  };

  nativeBuildInputs = [ _7zz ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -R Ghostty.app $out/Applications
    runHook postInstall
  '';

  meta = with lib; {
    description = "Ghostty is a fast, feature-rich, and cross-platform terminal emulator that uses platform-native UI and GPU acceleration";
    homepage = "https://ghostty.org";
    license = licenses.mit;
    mainProgram = "Ghostty.app";
    platforms = platforms.darwin;
  };
}
