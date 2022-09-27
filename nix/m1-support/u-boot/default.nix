{ lib
, fetchFromGitHub
, pkgs
, pkgsCross
, m1n1
}: let
  # u-boot's buildInputs get a different hash and don't build right if we try to
  # cross-build for aarch64 on itself for whatever reason
  buildPkgs = if pkgs.stdenv.system == "aarch64-linux" then pkgs else pkgsCross.aarch64-multiplatform;
in (buildPkgs.buildUBoot rec {
  src = fetchFromGitHub {
    # tracking: https://github.com/AsahiLinux/PKGBUILDs/blob/main/uboot-asahi/PKGBUILD
    owner = "AsahiLinux";
    repo = "u-boot";
    rev = "asahi-v2022.07-3";
    hash = "sha256-Je8h8kstWTBfrITsOrSAPzHjiSe7pIDKPLKoWUAK9ZE=";
  };
  version = "2022.07_rc100.asahi3";

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
