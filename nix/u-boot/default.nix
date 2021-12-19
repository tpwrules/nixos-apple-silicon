{ lib
, fetchFromGitHub
, pkgsCross
, m1n1
, withDeviceTree ? "t8103-j274"
}: (pkgsCross.aarch64-multiplatform.buildUBoot rec {
  src = fetchFromGitHub {
    owner = "kettenis";
    repo = "u-boot";
    rev = "fd6480ff7986e61848bc96dc43a279c80ba27cc9";
    hash = "sha256-K79/s26ec3cOLlbbY+Im+m87Zec761xTkZJJ9Ni3sLI=";
  };
  version = "unstable-2021-12-19";

  defconfig = "apple_m1_defconfig";
  extraMakeFlags = [ "DEVICE_TREE=${withDeviceTree}" ];
  extraMeta.platforms = [ "aarch64-linux" ];
  filesToInstall = [ "u-boot.macho" ];
  extraConfig = ''
    CONFIG_IDENT_STRING=" ${version} ${withDeviceTree}"
  '';
}).overrideAttrs (o: {
  patches = [
    ./0001-m1n1-fdt-compat.patch
    ./0001-add-extlinux-vars.patch
  ];

  preInstall = ''
    cat ${m1n1}/build/m1n1.macho u-boot.dtb u-boot-nodtb.bin > u-boot.macho
  '';
})
