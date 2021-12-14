{ stdenv
, lib
, fetchFromGitHub
, pkgsCross
, python3
, dtc
, imagemagick
}: let
  pyenv = python3.withPackages (p: with p; [
    construct
    pyserial
  ]); 
in stdenv.mkDerivation {
  pname = "m1n1";
  version = "unstable-2021-12-13";

  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "m1n1";
    rev = "e8b30c93257b4d9d882463b573815f5c4d89681d";
    hash = "sha256-qFQJ2+42TD7cTmmPZqlUaDRtWtdZEAzjXzBQfj2mUwQ=";
    fetchSubmodules = true;
  };

  makeFlags = [ "ARCH=aarch64-unknown-linux-gnu-" ];

  nativeBuildInputs = [
    dtc
    imagemagick
    pkgsCross.aarch64-multiplatform.buildPackages.gcc
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,build,script}
    cp -r proxyclient $out/script
    cp -r tools $out/script
    cp build/m1n1.macho $out/build

    for toolpath in $out/script/proxyclient/tools/*.py; do
      tool=$(basename $toolpath .py)
      script=$out/bin/m1n1-$tool
      cat > $script <<EOF
#!/bin/sh
${pyenv}/bin/python $toolpath "\$@"
EOF
      chmod +x $script
    done

    runHook postInstall
  '';
}
