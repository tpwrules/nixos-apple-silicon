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
    # tracking: https://github.com/AsahiLinux/PKGBUILDs/blob/stable/uboot-asahi/PKGBUILD
    owner = "AsahiLinux";
    repo = "u-boot";
    rev = "asahi-v2022.10-1";
    hash = "sha256-/dtTJ+GxC2GFlqduAa2WWPGwktLjM7tUKus6/aUyPNQ=";
  };
  version = "2022.10.asahi1-1";

  defconfig = "apple_m1_defconfig";
  extraMeta.platforms = [ "aarch64-linux" ];
  filesToInstall = [
    "u-boot-nodtb.bin.gz"
    "m1n1-u-boot.bin"
  ];
  extraConfig = ''
    CONFIG_IDENT_STRING=" ${version}"
    CONFIG_VIDEO_FONT_4X6=n
    CONFIG_VIDEO_FONT_8X16=n
    CONFIG_VIDEO_FONT_SUN12X22=n
    CONFIG_VIDEO_FONT_TER12X24=n
    CONFIG_VIDEO_FONT_TER16X32=y
  '';
}).overrideAttrs (o: {
  # nixos's downstream patches are not applicable
  # however, we add in bigger u-boot fonts because the mac laptop screens are high-res
  # these patches obtained via:
  # https://git.alpinelinux.org/aports/tree/testing/u-boot-asahi
  patches = [ 
    ./apritzel-first5-video.patch
    ./mps-u-boot-ter12x24.patch 
  ];

  preInstall = ''
    # compress so that m1n1 knows U-Boot's size and can find things after it
    gzip -n u-boot-nodtb.bin
    cat ${m1n1}/build/m1n1.bin arch/arm/dts/t[68]*.dtb u-boot-nodtb.bin.gz > m1n1-u-boot.bin
  '';
})
