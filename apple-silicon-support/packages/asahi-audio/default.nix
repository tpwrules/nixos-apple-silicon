{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "asahi-audio";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "asahi-audio";
    rev = "v${version}";
    hash = "sha256-mQup46I1k9zApJ6O83SxQiip0htNCqYoiD8MSaZK7GI=";
  };

  preBuild = ''
    export PREFIX=$out

    readarray -t configs < <(\
          find . \
                -name '*.conf' -or \
                -name '*.json' -or \
                -name '*.lua'
    )

    substituteInPlace "''${configs[@]}" --replace \
          "/usr/share/asahi-audio" \
          "$out/share/asahi-audio"
  '';
}
