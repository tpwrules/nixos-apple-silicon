# this configuration is intended to have just enough stuff to get the disk,
# display, USB input, and network up so the user can build a real config.
# in the future we will just use the standard NixOS iso

# based vaguely on
# https://github.com/samueldr/cross-system/blob/master/configuration.nix

{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/installation-device.nix")
    (modulesPath + "/installer/cd-dvd/iso-image.nix")
  ];

  # Adds terminus_font for people with HiDPI displays
  console.packages = [ pkgs.terminus_font ];

  # ISO naming.
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";

  # EFI booting
  isoImage.makeEfiBootable = true;

  # An installation media cannot tolerate a host config defined file
  # system layout on a fresh machine, before it has been formatted.
  swapDevices = lib.mkOverride 60 [ ];
  fileSystems = lib.mkOverride 60 config.lib.isoFileSystems;

  boot.postBootCommands = ''
    for o in $(</proc/cmdline); do
      case "$o" in
        live.nixos.passwd=*)
          set -- $(IFS==; echo $o)
          echo "nixos:$2" | ${pkgs.shadow}/bin/chpasswd
          ;;
      esac
    done
  '';

  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  environment.systemPackages = [
    pkgs.gptfdisk
  ];

  # save space and compilation time. might revise?
  hardware.enableAllFirmware = lib.mkForce false;
  hardware.enableRedistributableFirmware = lib.mkForce false;
  sound.enable = false;
  documentation.nixos.enable = lib.mkOverride 49 false;
  system.extraDependencies = lib.mkForce [ ];

  networking.wireless.enable = true;
  networking.wireless.userControlled.enable = true;
  systemd.services.wpa_supplicant.wantedBy = lib.mkOverride 50 [];

  # avoids the need to cross-compile rustc and spidermonkey and polkit
  nixpkgs.overlays = [
    (self: super: {
      wpa_supplicant = super.wpa_supplicant.override {
        withPcsclite = false;
      };
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
}
