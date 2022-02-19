{ lib
, fetchFromGitHub
, pkgsCross
, m1n1
, withDeviceTree ? "t8103-j274"
}: (pkgsCross.aarch64-multiplatform.buildUBoot rec {
  src = fetchFromGitHub {
    owner = "kettenis";
    repo = "u-boot";
    rev = "0a50f5d0acb2a907686c9a1b2c6b48d1cd62cb63";
    hash = "sha256-BrWNtRj5QFCjVb+0EWrrEeMgNfT0Z9u8HbK5FgXfPOQ=";
  };
  version = "unstable-2022-02-19";

  defconfig = "apple_m1_defconfig";
  extraMakeFlags = [ "DEVICE_TREE=${withDeviceTree}" ];
  extraMeta.platforms = [ "aarch64-linux" ];
  filesToInstall = [ "u-boot.macho" "u-boot.bin" ];
  extraConfig = ''
    CONFIG_IDENT_STRING=" ${version} ${withDeviceTree}"
  '';
}).overrideAttrs (o: {
  # nixos's downstream patches are not applicable
  patches = [ ];

  preInstall = ''
    cat ${m1n1}/build/m1n1.macho u-boot.dtb u-boot-nodtb.bin > u-boot.macho
    cat ${m1n1}/build/m1n1.bin u-boot.dtb u-boot-nodtb.bin > u-boot.bin
  '';
})
