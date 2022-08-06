{ lib
, fetchFromGitHub
, pkgsCross
, m1n1
}: (pkgsCross.aarch64-multiplatform.buildUBoot rec {
  src = fetchFromGitHub {
    # tracking: https://github.com/AsahiLinux/PKGBUILDs/blob/main/uboot-asahi/PKGBUILD
    owner = "AsahiLinux";
    repo = "u-boot";
    rev = "asahi-v2022.07-2";
    hash = "sha256-VOOkLQdQXnRD/SMUePPNKgHLNXWR815mQx8t3W95m5E=";
  };
  version = "2022.07_rc100.asahi2";

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
