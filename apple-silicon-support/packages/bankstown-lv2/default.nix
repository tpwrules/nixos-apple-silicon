{ lib
, lv2
, pkg-config
, rustPlatform
, fetchFromGitHub
, fetchpatch
}:

rustPlatform.buildRustPackage rec {
  pname = "bankstown-lv2";
  # tracking: https://src.fedoraproject.org/rpms/rust-bankstown-lv2
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "chadmed";
    repo = "bankstown";
    rev = version;
    hash = "sha256-dPgQuwwY1FEsH65vYClTtV/c+0cB5uq8QYszeHPdIQA=";
  };

  cargoSha256 = "sha256-HIW4mJ1VQSzOIksmJ2d4FQjTfU2Zk6xva1mYUk6MQCI=";

  installPhase = ''
    export LIBDIR=$out/lib
    mkdir -p $LIBDIR

    make
    make install
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    lv2
  ];
}
