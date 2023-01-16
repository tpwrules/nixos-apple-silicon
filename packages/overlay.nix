final: prev: {
  linux-asahi = final.callPackage ./kernel { };
  m1n1 = final.callPackage ./m1n1 { };
  u-boot = final.callPackage ./u-boot { };
  asahi-fwextract = final.callPackage ./asahi-fwextract { };
  mesa-asahi-edge = final.callPackage ./mesa-asahi-edge { };
  # TODO: package alsa-ucm-conf-asahi for headphone jack support
}
