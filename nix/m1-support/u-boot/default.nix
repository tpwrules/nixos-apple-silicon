{ lib
, fetchFromGitHub
, pkgsCross
, m1n1
}: (pkgsCross.aarch64-multiplatform.buildUBoot rec {
  src = fetchFromGitHub {
    # tracking branch: https://github.com/AsahiLinux/u-boot/tree/releng/installer-release
    owner = "AsahiLinux";
    repo = "u-boot";
    rev = "300817d324f73c30c998a10435d5d830b58df894";
    hash = "sha256-6q4l1gHAlaGM7ktlCBmehb/ZNvmpt1eah6tTdsQJfxM=";
  };
  version = "unstable-2022-07-11";

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
