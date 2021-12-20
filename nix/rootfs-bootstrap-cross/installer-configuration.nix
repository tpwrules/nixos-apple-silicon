# this configuration is intended to have just enough stuff to get the disk,
# display, USB input, and network up so the user can build a real config.

# based on https://github.com/samueldr/cross-system/blob/master/configuration.nix

{ config, pkgs, lib, nixpkgsPath, ... }:

{
  imports = [
    (nixpkgsPath + "/nixos/modules/profiles/minimal.nix")
    (nixpkgsPath + "/nixos/modules/profiles/installation-device.nix")
    (nixpkgsPath + "/nixos/modules/installer/sd-card/sd-image.nix")
  ];

  sdImage.populateRootCommands = ''
    mkdir -p ./files/boot
    ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot

    mkdir -p ./files/etc/nixos/kernel
    cp -r ${../kernel}/* ./files/etc/nixos/kernel
    cp ${./sample-configuration.nix} ./files/etc/nixos/configuration.nix
    chmod +w -R ./files/etc/nixos/
  '';

  installer.cloneConfig = false;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.consoleLogLevel = 7;

  boot.kernelParams = [
    "earlycon"
    "console=ttySAC0,1500000"
    "console=tty0"
    "debug"
    "boot.shell_on_fail"
  ];

  boot.kernelPackages = pkgs.callPackage ../kernel { nativeBuild = false; };

  # our kernel config is weird and doesn't have these modules as modules
  boot.initrd.availableKernelModules = lib.mkForce [];

  # save space and compilation time. might revise?
  hardware.enableAllFirmware = lib.mkForce false;
  hardware.enableRedistributableFirmware = lib.mkForce false;
  sound.enable = false;
  networking.wireless.enable = false;
  documentation.nixos.enable = lib.mkOverride 49 false;
  system.extraDependencies = lib.mkForce [ ];

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

  # (Failing build in a dep to be investigated)
  security.polkit.enable = false;

  # cifs-utils fails to cross-compile
  # Let's simplify this by removing all unneeded filesystems from the image.
  boot.supportedFilesystems = lib.mkForce [ "vfat" ];

  # texinfoInteractive has trouble cross-compiling
  documentation.info.enable = lib.mkForce false;

  # `xterm` is being included even though this is GUI-less.
  # → https://github.com/NixOS/nixpkgs/pull/62852
  services.xserver.desktopManager.xterm.enable = lib.mkForce false;

  # ec6224b6cd147943eee685ef671811b3683cb2ce re-introduced udisks in the installer
  # udisks fails due to gobject-introspection being not cross-compilation friendly.
  services.udisks2.enable = lib.mkForce false;

  networking.firewall.enable = false;

  nixpkgs.crossSystem = {
    system = "aarch64-linux";
  };
}
