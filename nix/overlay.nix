self: super:
let
  pkgs = self;
  lib = pkgs.lib;
in {
  # main scope
  nixos-m1 = lib.makeScope pkgs.newScope (self: with self; {
    m1n1 = callPackage ./m1-support/m1n1 {};
    u-boot = callPackage ./m1-support/u-boot {};
    installer-bootstrap = callPackage ./installer-bootstrap {};
    installer-bootstrap-cross = callPackage ./installer-bootstrap {
      crossBuild = true;
    };
    asahi-fwextract = callPackage ./m1-support/asahi-fwextract {};
  });
}
