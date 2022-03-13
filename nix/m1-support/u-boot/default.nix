{ lib
, fetchFromGitHub
, pkgsCross
, m1n1
}: (pkgsCross.aarch64-multiplatform.buildUBoot rec {
  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "u-boot";
    rev = "64cabe2491f90cf38674cc90c1f97cc26e4f08e7";
    hash = "sha256-0BxZIBZNadW3L+LcnwpoMrpt6vMExtqYPZyWsjTIxbg=";
  };
  version = "unstable-2022-03-11";

  defconfig = "apple_m1_defconfig";
  extraMeta.platforms = [ "aarch64-linux" ];
  filesToInstall = [ "m1n1-u-boot.macho" "m1n1-u-boot.bin" ];
  extraConfig = ''
    CONFIG_IDENT_STRING=" ${version}"
  '';
}).overrideAttrs (o: {
  # nixos's downstream patches are not applicable
  patches = [ ];

  preInstall = ''
    cat ${m1n1}/build/m1n1.macho arch/arm/dts/t[68]*.dtb u-boot-nodtb.bin > m1n1-u-boot.macho
    cat ${m1n1}/build/m1n1.bin arch/arm/dts/t[68]*.dtb u-boot-nodtb.bin > m1n1-u-boot.bin
  '';
})
