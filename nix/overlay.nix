self: super:
let
  pkgs = self;
  lib = pkgs.lib;
in {
  # main scope
  nixos-m1 = lib.makeScope pkgs.newScope (self: let
      installer-config = self.callPackage ./installer-bootstrap {};
      installer-config-cross = self.callPackage ./installer-bootstrap { crossBuild = true; };
    in {
      m1n1 = self.callPackage ./m1-support/m1n1 {};
      u-boot = self.callPackage ./m1-support/u-boot {};
      asahi-fwextract = self.callPackage ./m1-support/asahi-fwextract {};

      installer-bootstrap = installer-config.system.build.isoImage;
      installer-bootstrap-cross = installer-config-cross.system.build.isoImage;
      
      inherit installer-config installer-config-cross;
    });
}
