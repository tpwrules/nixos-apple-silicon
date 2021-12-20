self: super:
let
  pkgs = self;
  lib = pkgs.lib;

  # u-boot only works on M1 regular for now.
  # device name to DTB name list is available here:
  # https://github.com/AsahiLinux/docs/wiki/Devices
  # e.g. the M1 2020 Mac Mini's device tree name is t8103-j274
  compatibleDTs = [
    "t8103-j274"
    "t8103-j293"
    "t8103-j313"
    "t8103-j456"
    "t8103-j457"
  ];
in {
  # main scope
  nixos-m1 = lib.makeScope pkgs.newScope (self: with self; {
    m1n1 = callPackage ./m1n1 {};
    u-boot = lib.genAttrs compatibleDTs (
      name: callPackage ./u-boot { withDeviceTree = name; }
    );
    rootfs-bootstrap-cross = callPackage ./rootfs-bootstrap-cross {};
    installer-bootstrap-cross = callPackage ./installer-bootstrap-cross {};
  });
}
