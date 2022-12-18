self: super:
{
  # nb. below may actually *require* overrides to reference
  # nb. inconsistecy of pkg definition location is a smell
  asahi-fwextract = self.callPackage ./asahi-fwextract {};
  boot-m1n1 = self.callPackage ./boot-m1n1 {};
  asahi-kernel = self.callPackage ./kernel/package.nix {};
  m1n1 = self.callPackage ./m1n1 {};
  peripheral-firmware = self.callPackage ./peripheral-firmware/package.nix {};
  u-boot = self.callPackage ./u-boot {};
}

