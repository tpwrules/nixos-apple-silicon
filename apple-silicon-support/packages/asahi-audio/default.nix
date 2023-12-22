{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "asahi-audio";
  # tracking: https://src.fedoraproject.org/rpms/asahi-audio
  version = "1.6";

  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "asahi-audio";
    rev = "v${version}";
    hash = "sha256-NxTQD742U2FUZNmw7RHuOruMuTRLtAh1HDlMV9EzQkg=";
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
