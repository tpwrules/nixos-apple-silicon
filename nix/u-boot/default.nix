{ lib
, fetchFromGitHub
, pkgsCross
, m1n1
, withDeviceTree ? "t8103-j274"
}: (pkgsCross.aarch64-multiplatform.buildUBoot rec {
  src = fetchFromGitHub {
    owner = "kettenis";
    repo = "u-boot";
    rev = "9e65c625e516cb9e80fc2e96fae131e2bb9308ed";
    hash = "sha256-z6ww8K/03qpBDZnd1qzg5aXHi5d7V09V1UnjxCf9gRU=";
  };
  version = "unstable-2021-12-23";

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
