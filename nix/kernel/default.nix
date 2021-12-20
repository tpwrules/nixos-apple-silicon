# the Asahi Linux kernel and options that must go along with it

{ config, pkgs, lib, ... }:
{
  # IMPORTANT: if you have to build the kernel on the Mac itself, set
  # nativeBuild here to `true`. If you don't, Nix will complain that it
  # cannot find an x86_64-linux builder.
  boot.kernelPackages = pkgs.callPackage ./package.nix { nativeBuild = false; };

  # our kernel config is weird and doesn't really have any modules
  boot.initrd.availableKernelModules = lib.mkForce [];

  # the relevant nf_tables kernel modules are not compiled yet so the firewall
  # will not start
  networking.firewall.enable = lib.mkForce false;

  # kernel parameters that are useful for debugging
  boot.consoleLogLevel = 7;
  boot.kernelParams = [
    "earlycon"
    "console=ttySAC0,1500000"
    "console=tty0"
    "debug"
    "boot.shell_on_fail"
  ];

  hardware.wirelessRegulatoryDatabase = true;
  hardware.firmware = [
    # all the firmware is big, but including the tigon one avoids an awkward
    # minute long hang on mac mini
    (pkgs.stdenv.mkDerivation {
      name = "tigon-firmware";
      buildCommand = ''
        mkdir -p $out/lib/firmware
        cp -r ${pkgs.firmwareLinuxNonfree}/lib/firmware/tigon $out/lib/firmware
      '';
    })
  ];
}
