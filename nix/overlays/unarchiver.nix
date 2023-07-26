self: super: {

  unarchiver = super.stdenvNoCC.mkDerivation rec {
    name = "theunarchiver";
    inherit (src) version;
    src = super.sources.unarchiver;
    unpackPhase = ''
      undmg $src
    '';
    nativeBuildInputs = [ self.undmg ];
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out/Applications
      cp -r *.app $out/Applications
    '';
  };

}
