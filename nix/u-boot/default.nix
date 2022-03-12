{ lib
, fetchFromGitHub
, pkgsCross
, m1n1
, withDeviceTree ? "t8103-j274"
}: (pkgsCross.aarch64-multiplatform.buildUBoot rec {
  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "u-boot";
    rev = "64cabe2491f90cf38674cc90c1f97cc26e4f08e7";
    hash = "sha256-0BxZIBZNadW3L+LcnwpoMrpt6vMExtqYPZyWsjTIxbg=";
  };
  version = "unstable-2022-03-11";

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
