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
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "chadmed";
    repo = "bankstown";
    rev = version;
    hash = "sha256-IThXEY+mvT2MCw0PSWU/182xbUafd6dtm6hNjieLlKg=";
  };

  cargoSha256 = "sha256-yRzM4tcYc6mweTpLnnlCeKgP00L2wRgHamtUzK9Kstc=";

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
