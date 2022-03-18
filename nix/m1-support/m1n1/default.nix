{ stdenv
, lib
, fetchFromGitHub
, pkgsCross
, python3
, dtc
, imagemagick
, isRelease ? false
, withTools ? true
, withChainloading ? false
, rust-bin ? null
}:

assert withChainloading -> rust-bin != null;

let
  pyenv = python3.withPackages (p: with p; [
    construct
    pyserial
  ]);

  rustenv = rust-bin.selectLatestNightlyWith (toolchain: toolchain.minimal.override {
    targets = [ "aarch64-unknown-none-softfloat" ];
  });
in stdenv.mkDerivation {
  pname = "m1n1";
  version = "unstable-2022-03-18";

  src = fetchFromGitHub {
    # tracking branch: https://github.com/AsahiLinux/m1n1/tree/main
    owner = "AsahiLinux";
    repo = "m1n1";
    rev = "0a1a9348c32e2e44374720cd9d68cbe81cf696df";
    hash = "sha256-fW1r0/k31wO89ob4Be27CrATkf4JnWkJGN8sgH3Ulj4=";
    fetchSubmodules = true;
  };

  makeFlags = [ "ARCH=aarch64-unknown-linux-gnu-" ]
    ++ lib.optional isRelease "RELEASE=1"
    ++ lib.optional withChainloading "CHAINLOADING=1";

  nativeBuildInputs = [
    dtc
    imagemagick
    pkgsCross.aarch64-multiplatform.buildPackages.gcc
  ] ++ lib.optional withChainloading rustenv;

  postPatch = ''
    substituteInPlace proxyclient/m1n1/asm.py \
      --replace 'aarch64-linux-gnu-' 'aarch64-unknown-linux-gnu-' \
      --replace 'TOOLCHAIN = ""' 'TOOLCHAIN = "'$out'/toolchain-bin/"'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/build
    cp build/m1n1.macho $out/build
    cp build/m1n1.bin $out/build
  '' + (lib.optionalString withTools ''
    mkdir -p $out/{bin,script,toolchain-bin}
    cp -r proxyclient $out/script
    cp -r tools $out/script

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
  '') + ''
    runHook postInstall
  '';
}
