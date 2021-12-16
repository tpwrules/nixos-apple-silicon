{ lib
, fetchFromGitHub
, pkgsCross
, m1n1
, withDeviceTree ? "t8103-j274"
}: (pkgsCross.aarch64-multiplatform.buildUBoot {
  src = fetchFromGitHub {
    owner = "kettenis";
    repo = "u-boot";
    rev = "4f0f957e8e8f6ccb4d4b616d7954e85478e3d7e2";
    hash = "sha256-UedxwqICoxqkTKzesMF0oVSLffVZQGNNKSgQkXRgP5s=";
  };
  version = "unstable-2021-12-12";

  defconfig = "apple_m1_defconfig";
  extraMakeFlags = [ "DEVICE_TREE=${withDeviceTree}" ];
  extraMeta.platforms = [ "aarch64-linux" ];
  filesToInstall = [ "u-boot.macho" ];
}).overrideAttrs (o: {
  patches = [
    ./0001-m1n1-fdt-compat.patch
  ];

  # postPatch = ''
  #   substituteInPlace configs/apple_m1_defconfig \
  #     --replace 'nvme scan;' ""
  # '';

  preInstall = ''
    cat ${m1n1}/build/m1n1.macho u-boot.dtb u-boot-nodtb.bin > u-boot.macho
  '';
})
