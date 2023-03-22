{ lib
, fetchFromGitHub
, fetchpatch
, buildUBoot
, m1n1
}:

(buildUBoot rec {
  src = fetchFromGitHub {
    # tracking: https://github.com/AsahiLinux/PKGBUILDs/blob/main/uboot-asahi/PKGBUILD
    owner = "AsahiLinux";
    repo = "u-boot";
    rev = "asahi-v2023.01-3";
    hash = "sha256-UJEQ+BJ2AhgE6MvBRrG/vI6c4F7+Qt1GUejCa5SoeQo=";
  };
  version = "2023.01.asahi3-1";

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
  patches = [ 
    (fetchpatch {
      url = "https://git.alpinelinux.org/aports/plain/testing/u-boot-asahi/apritzel-first5-video.patch?id=990110f35b50b74bdb4e902d94fa15b07a8eac9e";
      sha256 = "sha256-QPvJYxIcQBHbwsj7l96qGUZSipk1sB3ZyniD1Io18dY=";
      revert = false;
    })

    (fetchpatch {
      url = "https://git.alpinelinux.org/aports/plain/testing/u-boot-asahi/mps-u-boot-ter12x24.patch?id=990110f35b50b74bdb4e902d94fa15b07a8eac9e";
      sha256 = "sha256-wrQpIYiuNRi/p2p290KCGPmuRxFEOPlbICoFvd+E8p0=";
      revert = false;
    })
  ];

  preInstall = ''
    # compress so that m1n1 knows U-Boot's size and can find things after it
    gzip -n u-boot-nodtb.bin
    cat ${m1n1}/build/m1n1.bin arch/arm/dts/t[68]*.dtb u-boot-nodtb.bin.gz > m1n1-u-boot.bin
  '';
})
