{ lib
, fetchFromGitHub
, pkgsCross
, m1n1
, withDeviceTree ? "t8103-j274"
}: (pkgsCross.aarch64-multiplatform.buildUBoot {
  src = fetchFromGitHub {
    owner = "kettenis";
    repo = "u-boot";
    rev = "9b6b6ed5a086a83f0e372ee62a88b892e9c2c830";
    hash = "sha256-QrelJxN7Wv547NVUc62zGk/HfSpICMkLIC0Px4BD3AI=";
  };
  version = "unstable-2021-12-18";

  defconfig = "apple_m1_defconfig";
  extraMakeFlags = [ "DEVICE_TREE=${withDeviceTree}" ];
  extraMeta.platforms = [ "aarch64-linux" ];
  filesToInstall = [ "u-boot.macho" ];
}).overrideAttrs (o: {
  patches = [
    ./0001-m1n1-fdt-compat.patch
    ./0001-apple-nvme-remove.patch
  ];

  preInstall = ''
    cat ${m1n1}/build/m1n1.macho u-boot.dtb u-boot-nodtb.bin > u-boot.macho
  '';
})
