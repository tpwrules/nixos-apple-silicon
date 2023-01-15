final: prev: {
  m1n1 = final.callPackage ./m1-support/m1n1 {};
  u-boot = final.callPackage ./m1-support/u-boot {};
  asahi-fwextract = final.callPackage ./m1-support/asahi-fwextract {};
  # TODO: package alsa-ucm-conf-asahi for headphone jack support
}
