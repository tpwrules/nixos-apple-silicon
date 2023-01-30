final: prev: {
  linux-asahi = final.callPackage ./linux-asahi { };
  m1n1 = final.callPackage ./m1n1 { };
  uboot-asahi = final.callPackage ./uboot-asahi { };
  asahi-fwextract = final.callPackage ./asahi-fwextract { };
  mesa-asahi-edge = final.callPackage ./mesa-asahi-edge { inherit (prev) mesa; };
  # TODO: package alsa-ucm-conf-asahi for headphone jack support
}
