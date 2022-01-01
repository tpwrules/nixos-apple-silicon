{ lib
, fetchFromGitHub
, pkgsCross
, m1n1
, withDeviceTree ? "t8103-j274"
}: (pkgsCross.aarch64-multiplatform.buildUBoot rec {
  src = fetchFromGitHub {
    owner = "kettenis";
    repo = "u-boot";
    rev = "9581098cbe247435983907fa8db71c5395d36315";
    hash = "sha256-T/75coa6XhLfbvYP18S92Tgy/Hb2AW6RRxLa+rdFlRo=";
  };
  version = "unstable-2021-12-29";

  defconfig = "apple_m1_defconfig";
  extraMakeFlags = [ "DEVICE_TREE=${withDeviceTree}" ];
  extraMeta.platforms = [ "aarch64-linux" ];
  filesToInstall = [ "u-boot.macho" "u-boot.bin" ];
  extraConfig = ''
    CONFIG_IDENT_STRING=" ${version} ${withDeviceTree}"
  '';
}).overrideAttrs (o: {
  # upstream patches are not applicable
  patches = [
    # stop EFI from spending 99% of its time polling the USB keybord instead of
    # reading disk sectors
    ./0001-fix-slow-boot.patch
  ];

  preInstall = ''
    cat ${m1n1}/build/m1n1.macho u-boot.dtb u-boot-nodtb.bin > u-boot.macho
    cat ${m1n1}/build/m1n1.bin u-boot.dtb u-boot-nodtb.bin > u-boot.bin
  '';
})
