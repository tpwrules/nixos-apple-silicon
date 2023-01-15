final: prev: {
  m1n1 = final.callPackage ./m1n1 { };
  u-boot = final.callPackage ./u-boot { };
  asahi-fwextract = final.callPackage ./asahi-fwextract { };
  # TODO: package alsa-ucm-conf-asahi for headphone jack support
}
