{ stdenv
, lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "ash";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "avamsi";
    repo = "ash";
    rev = "main";
    hash = "sha256-PfNyaVGda4vodNX4gYgb4i/qAKm9PkVjFh8ORj14fZc";
  };

  vendorHash = "sha256-iJu1I7/bxAJxErbf2MnLIoYlF6p+aGEGj54+HcyeX+k=";

  doCheck = false;

  meta = with lib; {
    description = "a hybrid between getopts and 'sh -c'";
    homepage = "https://github.com/avamsi/ash";
    license = licenses.unlicense;
    platforms = platforms.unix;
  };
}
