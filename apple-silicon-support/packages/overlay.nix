final: prev: {
  linux-asahi = final.callPackage ./linux-asahi { };
  m1n1 = final.callPackage ./m1n1 { };
  uboot-asahi = final.callPackage ./uboot-asahi { };
  asahi-fwextract = final.callPackage ./asahi-fwextract { };
  mesa-asahi-edge = final.callPackage ./mesa-asahi-edge { inherit (prev) mesa; };
  alsa-ucm-conf-asahi = final.callPackage ./alsa-ucm-conf-asahi { inherit (prev) alsa-ucm-conf; };
  speakersafetyd = final.callPackage ./speakersafetyd { };
  bankstown-lv2 = final.callPackage ./bankstown-lv2 { };
  asahi-audio = final.callPackage ./asahi-audio { };
}
