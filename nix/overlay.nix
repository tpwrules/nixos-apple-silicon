self: super:
let
  pkgs = self;
  lib = pkgs.lib;
in {
  # main scope
  nixos-m1 = lib.makeScope pkgs.newScope (self: with self; {
    m1n1 = callPackage ./m1n1 {};
  });
}
