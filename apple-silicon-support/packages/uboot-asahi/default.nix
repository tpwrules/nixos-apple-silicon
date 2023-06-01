{ stdenv
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
    # This commit contains various fixes (mainly usb-related crashes), so use it instead of tag
    rev = "4ff04ece6d0a0293b570eadf213995b944833937";
    hash = "sha256-vGuZrT+siynhXWnvvR3b3v2f/imF5qapyO0EgMc+4ZQ=";
  };
  # Should we use another version to not confuse with tag?
  version = "2023.04.asahi1-1";

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
  # Without that build fails for some reason (buildUBoot adds DTC=dtc by default, looks like that is the reason) 
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/misc/uboot/default.nix#L89
  makeFlags = [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];
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
