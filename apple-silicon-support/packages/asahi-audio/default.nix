{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "asahi-audio";
  # tracking: https://src.fedoraproject.org/rpms/asahi-audio
  version = "2.5";

  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "asahi-audio";
    rev = "v${version}";
    hash = "sha256-u+Ef2vA/EQ3b5wsCNPOGEPUk/Vah0mS71gDVhCLBq+g=";
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
          "$out/asahi-audio"
  '';

  postInstall = ''
    # no need to link the asahi-audio dir globally
    mv $out/share/asahi-audio $out
  '';
}
