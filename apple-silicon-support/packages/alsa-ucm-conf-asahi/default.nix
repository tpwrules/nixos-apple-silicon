{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "alsa-ucm-conf-asahi";
  version = "5";

  src = fetchFromGitHub {
    # tracking: https://src.fedoraproject.org/rpms/alsa-ucm-asahi
    owner = "AsahiLinux";
    repo = "alsa-ucm-conf-asahi";
    rev = "v${version}";
    hash = "sha256-daUNz5oUrPfSMO0Tqq/WbtiLHMOtPeQQlI+juGrhTxw=";
  };

  postInstall = ''
    mkdir -p $out/share/alsa
    cp -r ${src}/ucm2 $out/share/alsa
  '';
}
