final: prev: {
  linux-asahi = final.callPackage ./linux-asahi { };
  m1n1 = final.callPackage ./m1n1 { };
  uboot-asahi = final.callPackage ./uboot-asahi { };
  asahi-fwextract = final.callPackage ./asahi-fwextract { };
  mesa-asahi-edge = final.callPackage ./mesa-asahi-edge { };
  alsa-ucm-conf-asahi = final.callPackage ./alsa-ucm-conf-asahi { inherit (prev) alsa-ucm-conf; };
  asahi-audio = final.callPackage ./asahi-audio { };

  # chromium/v8 enabled 'decommit-pooled-pages' in v131, breaking chromium on
  # systems with 16k pages
  chromium = prev.chromium.override {
    commandLineArgs = "--js-flags=--no-decommit-pooled-pages";
  };
}
