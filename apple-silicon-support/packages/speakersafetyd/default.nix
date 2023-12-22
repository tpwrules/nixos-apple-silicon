{ rustPlatform
, stdenv
, rust
, fetchCrate
, pkg-config
, alsa-lib
}:

rustPlatform.buildRustPackage rec {
  pname = "speakersafetyd";
  # tracking: https://src.fedoraproject.org/rpms/rust-speakersafetyd
  version = "0.1.9";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ alsa-lib ];

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-I1fL1U4vqKxPS1t6vujMTdi/JAAOCcPkvUqv6FqkId4=";
  };
  cargoHash = "sha256-Adwct+qFhUsOIao8XqNK2zcn13DBlQNA+X4aRFeIAXM=";

  postPatch = ''
    substituteInPlace speakersafetyd.service --replace "/usr" "$out"
    substituteInPlace Makefile --replace "target/release" "target/${rust.lib.toRustTargetSpec stdenv.hostPlatform}/$cargoBuildType"
  '';

  installFlags = [
    "DESTDIR=${placeholder "out"}"
    "BINDIR=/bin"
    "SHAREDIR=/share"
    "TMPFILESDIR=/lib/tmpfiles.d"
  ];

  dontCargoInstall = true;
}
