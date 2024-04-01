{ version
, src
, providedConfigFiles
}:

{ stdenv
, lib
}:

stdenv.mkDerivation rec {
  pname = "asahi-audio";
  inherit version src;

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
  passthru = { inherit providedConfigFiles; };
}
