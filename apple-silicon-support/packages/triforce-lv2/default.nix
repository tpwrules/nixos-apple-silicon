{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "triforce-lv2";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "chadmed";
    repo = "triforce";
    rev = "${version}";
    hash = "sha256-Rv4FHDmmTELYwrxfWDt/TghspLQBGgiREaq3KV98EQY=";
  };
  
  useFetchCargoVendor = true;
  cargoHash = "sha256-ltrvwvrzRPtgB4y/TeIHhIQdWAfo2NHTeDYvDqTuPXE=";

  installPhase = ''
    export LIBDIR=$out/lib
    mkdir -p $LIBDIR

    make
    make install
  '';

  meta = with lib; {
    homepage = "https://github.com/chadmed/triforce";
    description = "Triforce implements a Minimum Variance Distortionless Response adaptive beamformer for the microphone array found in the Apple Silicon laptops";
    platforms = platforms.linux;
  };
}
