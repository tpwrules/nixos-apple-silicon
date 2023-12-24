{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "asahi-audio";
  # tracking: https://src.fedoraproject.org/rpms/asahi-audio
  # note: ensure that the providedConfigFiles list below is current!
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
          "$out/asahi-audio"
  '';

  postInstall = ''
    # no need to link the asahi-audio dir globally
    mv $out/share/asahi-audio $out
  '';

  # list of config files installed in $out/share/ and destined for
  # /etc/, from the `install -pm0644 conf/` lines in the Makefile. note
  # that the contents of asahi-audio/ stay in $out/ and the config files
  # are modified to point to them.
  passthru.providedConfigFiles = [
    "wireplumber/wireplumber.conf.d/99-asahi.conf"
    "wireplumber/policy.lua.d/85-asahi-policy.lua"
    "wireplumber/main.lua.d/85-asahi.lua"
    "wireplumber/scripts/policy-asahi.lua"
    "pipewire/pipewire.conf.d/99-asahi.conf"
    "pipewire/pipewire-pulse.conf.d/99-asahi.conf"
  ];
}
