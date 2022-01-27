# the Asahi Linux kernel and options that must go along with it

{ config, pkgs, lib, ... }:
{
  config = {
    boot.kernelPackages = pkgs.callPackage ./package.nix {
      crossBuild = config.boot.kernelBuildIsCross;
    };

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
    ];
  };

  options.boot.kernelBuildIsCross = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Set that the Asahi Linux kernel should be cross-compiled.";
  };
}
