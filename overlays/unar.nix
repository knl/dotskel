self: super: {

unar = super.stdenv.mkDerivation rec {
  name = "unar";
  inherit (src) version;
  src = super.sources.unar;
  buildInputs = [ self.unzip ];
  unpackPhase = ''
    unzip ${src}
  '';
  buildPhase = "";
  installPhase = ''
    mkdir -p $out/bin
    cp unar $out/bin
    cp lsar $out/bin
  '';
};

}
