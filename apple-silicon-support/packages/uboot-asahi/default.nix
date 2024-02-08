{ lib
, fetchFromGitHub
, buildUBoot
, m1n1
}:

(buildUBoot rec {
  src = fetchFromGitHub {
    # tracking: https://pagure.io/fedora-asahi/uboot-tools/commits/main
    owner = "AsahiLinux";
    repo = "u-boot";
    rev = "asahi-v2023.07.02-4";
    hash = "sha256-M4qkEyNgwV2AKSr5VzPGfhHo1kGy8Tw8TfyP36cgYjc=";
  };
  version = "2023.07.02.asahi4-1";

  defconfig = "apple_m1_defconfig";
  extraMeta.platforms = [ "aarch64-linux" ];
  filesToInstall = [
    "u-boot-nodtb.bin.gz"
    "m1n1-u-boot.bin"
  ];
  extraConfig = ''
    CONFIG_IDENT_STRING=" ${version}"
    CONFIG_CMD_NFS=n
    CONFIG_VIDEO_LOGO=n
    CONFIG_BOOTDELAY=2
    CONFIG_VIDEO_FONT_4X6=n
    CONFIG_VIDEO_FONT_8X16=n
    CONFIG_VIDEO_FONT_SUN12X22=n
    CONFIG_VIDEO_FONT_16X32=y
  '';
}).overrideAttrs (o: {
  # nixos's downstream patches are not applicable
  patches = [
    # fix Mac Studios with 8TB NVME SSDs
    ./8c9b59982d60847f7514d3367aa8cd0f9e178727.patch
    # cherry-pick fixes from upstream u-boot
    # so that Janne's patches apply cleanly
    ./7a2fee8d29a92eadac3fc656d2686ccd20c24a08.patch
    ./7432f68c53526980d0a2b2ffd54fe61141bb1178.patch
    ./0ab4f91a107832692781a367a1ef2173af75f108.patch
    ./a8f80409b06a39605aadaaf64bdbf71b31d463ca.patch
    ./648a4991d0713af656a2fa50ec8e708c2beb044e.patch
    ./b828ed7d79295cfebcb0f958f26a33664fae045c.patch
    ./04f3dcd503a537fab50329686874559dae8a1a22.patch
    ./01c76f1a64ba8cb3da9b26be481e289ee16960f0.patch
    ./9e55d09596a5b6ec1f8cbfc3e97d29b9929dee86.patch
    ./9899eef2cb41a9cde1dca87f3ddb041e347b177a.patch
    ./37db20d0a64132a7ae3d0223de6b93167d60bea4.patch
    ./617d7b545b6fa555f47944a10b1a1b261491e3b9.patch
    ./6d225ec0cc5251c540164b4303261d29f0ade644.patch
    ./7c00b80d48cbb28e5f6dfc232c344526e28f7176.patch
    # Janne Grunau's patches to fix the EFI console:
    # with these patches, the NixOS configuration boot
    # picker renders correctly, without all of the
    # goofy characters at the bottom
    ./6524e8095eeefda61c1daca2ffb19224dd65618f.patch
    ./ccca7c676023de6607f9ce91204b076045c8b6d1.patch
    ./f27a89f6afa226a92f5e241f5c4fef98f872b4af.patch
    ./a339b0112e45d6dbefcbf59d71928bd7702f46c6.patch
    ./826c4e38d45bf45f214f8bde6928ffb78bb42c66.patch
    ./9661d323264927941b1cd858b4bab349ee024c50.patch
    ./9b425d0b06881e377bef99b3192dba24dcd97e5a.patch
    ./e1c1bf91dc8b4f6c8aad61735c43e0cbdb448773.patch
    ./f9d39fa1479550fb766a7720a7ca933ad2854cf7.patch
    ./477c92689a374f13e5792a0216509b6696798c29.patch
  ];

  # flag somehow breaks DTC compilation so we remove it
  makeFlags = builtins.filter (s: s != "DTC=dtc") o.makeFlags;

  preInstall = ''
    # compress so that m1n1 knows U-Boot's size and can find things after it
    gzip -n u-boot-nodtb.bin
    cat ${m1n1}/build/m1n1.bin arch/arm/dts/t[68]*.dtb u-boot-nodtb.bin.gz > m1n1-u-boot.bin
  '';
})
