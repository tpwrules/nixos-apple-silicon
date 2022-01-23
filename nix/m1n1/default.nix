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
  version = "unstable-2022-01-18";

  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "m1n1";
    rev = "2bd7bf40201427de8517b8e1fdc0f90357c1b0d9";
    hash = "sha256-vkNwaOQjza0kxt/odTS8iKXUBDw2cmyhvLJgmHrGE6U=";
    fetchSubmodules = true;
  };

  makeFlags = [ "ARCH=aarch64-unknown-linux-gnu-" ];

  nativeBuildInputs = [
    dtc
    imagemagick
    pkgsCross.aarch64-multiplatform.buildPackages.gcc
  ];

  postPatch = ''
    substituteInPlace proxyclient/m1n1/asm.py \
      --replace 'aarch64-linux-gnu-' 'aarch64-unknown-linux-gnu-' \
      --replace 'TOOLCHAIN = ""' 'TOOLCHAIN = "'$out'/toolchain-bin/"'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,build,script,toolchain-bin}
    cp -r proxyclient $out/script
    cp -r tools $out/script
    cp build/m1n1.macho $out/build
    cp build/m1n1.bin $out/build

    for toolpath in $out/script/proxyclient/tools/*.py; do
      tool=$(basename $toolpath .py)
      script=$out/bin/m1n1-$tool
      cat > $script <<EOF
#!/bin/sh
${pyenv}/bin/python $toolpath "\$@"
EOF
      chmod +x $script
    done

    GCC=${pkgsCross.aarch64-multiplatform.buildPackages.gcc}
    BINUTILS=${pkgsCross.aarch64-multiplatform.buildPackages.binutils}
    REAL_BINUTILS=$(grep -o '/nix/store/[^ ]*binutils[^ ]*' $BINUTILS/nix-support/propagated-user-env-packages)

    ln -s $GCC/bin/*-gcc $out/toolchain-bin/
    ln -s $GCC/bin/*-ld $out/toolchain-bin/
    ln -s $REAL_BINUTILS/bin/*-objcopy $out/toolchain-bin/
    ln -s $REAL_BINUTILS/bin/*-objdump $out/toolchain-bin/
    ln -s $REAL_BINUTILS/bin/*-nm $out/toolchain-bin/

    runHook postInstall
  '';
}
