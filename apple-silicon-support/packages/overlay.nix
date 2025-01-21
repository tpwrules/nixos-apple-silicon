final: prev: {
  linux-asahi = final.callPackage ./linux-asahi { };
  m1n1 = final.callPackage ./m1n1 { };
  uboot-asahi = final.callPackage ./uboot-asahi { };
  asahi-fwextract = final.callPackage ./asahi-fwextract { };
  mesa-asahi-edge = final.callPackage ./mesa-asahi-edge { };
  alsa-ucm-conf-asahi = final.callPackage ./alsa-ucm-conf-asahi { };
  asahi-audio = final.callPackage ./asahi-audio { };
}
