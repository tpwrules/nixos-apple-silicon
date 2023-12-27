# the Asahi Linux kernel and options that must go along with it

{ config, pkgs, lib, ... }:
{
  config = {
    boot.kernelPackages = let
      pkgs' = config.hardware.asahi.pkgs;
    in
      pkgs'.linux-asahi.override {
        _kernelPatches = config.boot.kernelPatches;
        _4KBuild = config.hardware.asahi.use4KPages;
        withRust = config.hardware.asahi.withRust;
      };

    # we definitely want to use CONFIG_ENERGY_MODEL, and
    # schedutil is a prerequisite for using it
    # source: https://www.kernel.org/doc/html/latest/scheduler/sched-energy.html
    powerManagement.cpuFreqGovernor = lib.mkOverride 800 "schedutil";

    boot.initrd.includeDefaultModules = false;
    boot.initrd.availableKernelModules = [
      # list of initrd modules stolen from
      # https://github.com/AsahiLinux/asahi-scripts/blob/f461f080a1d2575ae4b82879b5624360db3cff8c/initcpio/install/asahi
      "tps6598x"
      "dwc3"
      # "dwc3-haps"
      "dwc3-of-simple"
      "xhci-pci"
      "phy-apple-atc"
      "phy-apple-dptx"
      "dockchannel-hid"
      "mux-apple-display-crossbar"
      "apple-dcp"
      "apple-z2"

      # additional stuff necessary to boot off USB for the installer
      # and if the initrd (i.e. stage 1) goes wrong
      "usb-storage"
      # "uas"
      # "udc_core"
      "xhci-hcd"
      "xhci-plat-hcd"
      "usbhid"
      "hid_generic"
    ];

    boot.kernelParams = [
      "earlycon"
      "console=ttySAC0,115200n8"
      "console=tty0"
      "boot.shell_on_fail"
      # Apple's SSDs are slow (~dozens of ms) at processing flush requests which
      # slows down programs that make a lot of fsync calls. This parameter sets
      # a delay in ms before actually flushing so that such requests can be
      # coalesced. Be warned that increasing this parameter above zero (default
      # is 1000) has the potential, though admittedly unlikely, risk of
      # UNBOUNDED data corruption in case of power loss!!!! Don't even think
      # about it on desktops!!
      "nvme_apple.flush_interval=0"
    ];

    # U-Boot does not support EFI variables
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

    # U-Boot does not support switching console mode
    boot.loader.systemd-boot.consoleMode = "0";

    # GRUB has to be installed as removable if the user chooses to use it
    boot.loader.grub = lib.mkDefault {
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
    };
  };

  imports = [
    ./edge.nix
  ];

  options.hardware.asahi.use4KPages = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Build the Asahi Linux kernel with 4K pages to improve compatibility in
      some cases at the cost of performance in others.
    '';
  };

  options.hardware.asahi.withRust = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Build the Asahi Linux kernel with Rust support.
    '';
  };
}
