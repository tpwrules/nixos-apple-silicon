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

  boot.postBootCommands = let
    asahi-fwextract = pkgs.callPackage ../m1-support/asahi-fwextract {};
  in ''
    for o in $(</proc/cmdline); do
      case "$o" in
        live.nixos.passwd=*)
          set -- $(IFS==; echo $o)
          echo "nixos:$2" | ${pkgs.shadow}/bin/chpasswd
          ;;
      esac
    done

    echo Extracting Asahi firmware...
    mkdir -p /tmp/.fwsetup/{esp,extracted}

    mount /dev/disk/by-partuuid/`cat /proc/device-tree/chosen/asahi,efi-system-partition` /tmp/.fwsetup/esp
    ${asahi-fwextract}/bin/asahi-fwextract /tmp/.fwsetup/esp/asahi /tmp/.fwsetup/extracted
    umount /tmp/.fwsetup/esp

    pushd /tmp/.fwsetup/
    cat /tmp/.fwsetup/extracted/firmware.cpio | ${pkgs.cpio}/bin/cpio -id --quiet --no-absolute-filenames
    mkdir -p /lib/firmware
    mv vendorfw/* /lib/firmware
    popd
    rm -rf /tmp/.fwsetup
  '';

  # can't legally be incorporated into the installer image
  # (and is automatically extracted at boot above)
  hardware.asahi.extractPeripheralFirmware = false;

  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  environment.systemPackages = [
    pkgs.gptfdisk
    pkgs.parted
    pkgs.cryptsetup
    pkgs.wget
    pkgs.curl
    pkgs.magic-wormhole
  ];

  # add in firmware so usb-ethernet adapters work
  hardware.enableAllFirmware = lib.mkForce true;
  hardware.enableRedistributableFirmware = lib.mkForce true;
  nixpkgs.config.allowUnfree = true;
  sound.enable = false;
  # avoid including non-reproducible dbus docs
  documentation.doc.enable = false;
  documentation.info.enable = lib.mkForce false;
  documentation.nixos.enable = lib.mkOverride 49 false;
  system.extraDependencies = lib.mkForce [ ];

  networking.wireless.enable = true;
  networking.wireless.userControlled.enable = true;
  systemd.services.wpa_supplicant.wantedBy = lib.mkOverride 50 [];

  nixpkgs.overlays = [
    (final: prev: {
      # disabling pcsclite avoids the need to cross-compile gobject
      # introspection stuff which works now but is slow and unnecessary
      wpa_supplicant = prev.wpa_supplicant.override {
        withPcsclite = false;
      };
      libfido2 = prev.libfido2.override {
        withPcsclite = false;
      };
      openssh = prev.openssh.overrideAttrs (old: {
        # we have to cross compile openssh ourselves for whatever reason
        # but the tests take quite a long time to run
        doCheck = false;
      });

      # avoids having to compile a bunch of big things (like texlive) to
      # compute translations
      util-linux = prev.util-linux.override {
        translateManpages = false;
      };
    })
  ];

  # avoids the need to cross-compile gobject introspection stuff which works
  # now but is slow and unnecessary
  security.polkit.enable = false;

  # get rid of warning that stateVersion is unset
  system.stateVersion = lib.mkDefault lib.trivial.release;
}
