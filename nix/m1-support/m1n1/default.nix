{ stdenv
, lib
, fetchFromGitHub
, pkgsCross
, python3
, dtc
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
in stdenv.mkDerivation rec {
  pname = "m1n1";
  version = "1.1.3";

  src = fetchFromGitHub {
    # tracking: https://github.com/AsahiLinux/PKGBUILDs/blob/main/m1n1/PKGBUILD
    owner = "AsahiLinux";
    repo = "m1n1";
    rev = "v${version}";
    hash = "sha256-S2HLBLmgER0ZZJ5Q4EX2f1KDxnol0yCDrloDMJaLwBE=";
    fetchSubmodules = true;
  };

  makeFlags = [ "ARCH=aarch64-unknown-linux-gnu-" ]
    ++ lib.optional isRelease "RELEASE=1"
    ++ lib.optional withChainloading "CHAINLOADING=1";

  nativeBuildInputs = [
    dtc
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

    ln -s $GCC/bin/*-gcc $out/toolchain-bin/
    ln -s $GCC/bin/*-ld $out/toolchain-bin/
    ln -s $GCC/bin/*-objcopy $out/toolchain-bin/
    ln -s $GCC/bin/*-objdump $out/toolchain-bin/
    ln -s $GCC/bin/*-nm $out/toolchain-bin/
  '') + ''
    runHook postInstall
  '';
}
