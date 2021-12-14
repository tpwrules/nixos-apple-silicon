{ lib
, fetchFromGitHub
, pkgsCross
, m1n1
, withDeviceTree ? "t8103-j274"
}: (pkgsCross.aarch64-multiplatform.buildUBoot {
  src = fetchFromGitHub {
    owner = "kettenis";
    repo = "u-boot";
    rev = "162f430ff2b3c61851bf27d2a198dd5e522c26a6";
    hash = "sha256-J9gvBogQw98hXHHTUgP6Tc4Aw0sK3zNSKB4BIXK6X7U=";
  };
  version = "unstable-2021-12-12";

  defconfig = "apple_m1_defconfig";
  extraMakeFlags = [ "DEVICE_TREE=${withDeviceTree}" ];
  extraMeta.platforms = [ "aarch64-linux" ];
  filesToInstall = [ "u-boot.macho" ];
}).overrideAttrs (o: {
  # not necessary and do not apply correctly
  patches = [];

  preInstall = ''
    cat ${m1n1}/build/m1n1.macho u-boot.dtb u-boot-nodtb.bin > u-boot.macho
  '';
})
