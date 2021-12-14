# this configuration is intended to have just enough stuff to get the disk,
# display, USB input, and network up so the user can build a real config.

# based on https://github.com/samueldr/cross-system/blob/master/configuration.nix

{ config, pkgs, lib, nixpkgsPath, ... }:

{
  imports = [
    (nixpkgsPath + "/nixos/modules/profiles/minimal.nix")
    (nixpkgsPath + "/nixos/modules/profiles/installation-device.nix")
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.consoleLogLevel = lib.mkDefault 7;

  boot.kernelParams = lib.mkForce ["earlycon" "console=ttySAC0,1500000" "console=tty0" "debug" "boot.shell_on_fail"];

  # save space and compilation time. might revise?
  sound.enable = false;
  networking.wireless.enable = false;
  documentation.enable = lib.mkOverride 51 false;
  documentation.nixos.enable = lib.mkOverride 51 false;
  system.extraDependencies = lib.mkOverride 51 (with pkgs; [
    stdenvNoCC # for runCommand
    busybox
    jq # for 
  ]);

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

  boot.kernelPackages = pkgs.callPackage ../kernel {};

  nixpkgs.crossSystem = {
    system = "aarch64-linux";
  };
}
