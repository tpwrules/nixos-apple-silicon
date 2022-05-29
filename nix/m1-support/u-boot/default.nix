{ lib
, fetchFromGitHub
, pkgsCross
, m1n1
}: (pkgsCross.aarch64-multiplatform.buildUBoot rec {
  src = fetchFromGitHub {
    # tracking branch: https://github.com/AsahiLinux/u-boot/tree/releng/installer-release
    owner = "AsahiLinux";
    repo = "u-boot";
    rev = "89dbe1bf776ac909319247bd66f73c5d2cdac838";
    hash = "sha256-//To8y+lbXBW3BPD45W1R5TUL9ElsBXBHNPT2r+1E9Y=";
  };
  version = "unstable-2022-03-19";

  defconfig = "apple_m1_defconfig";
  extraMeta.platforms = [ "aarch64-linux" ];
  filesToInstall = [
    "u-boot-nodtb.bin.gz"
    "m1n1-u-boot.macho"
    "m1n1-u-boot.bin"
  ];
  extraConfig = ''
    CONFIG_IDENT_STRING=" ${version}"
  '';
}).overrideAttrs (o: {
  # nixos's downstream patches are not applicable
  patches = [ ];

  preInstall = ''
    # compress so that m1n1 knows U-Boot's size and can find things after it
    gzip -n u-boot-nodtb.bin
    cat ${m1n1}/build/m1n1.macho arch/arm/dts/t[68]*.dtb u-boot-nodtb.bin.gz > m1n1-u-boot.macho
    cat ${m1n1}/build/m1n1.bin arch/arm/dts/t[68]*.dtb u-boot-nodtb.bin.gz > m1n1-u-boot.bin
  '';
})
