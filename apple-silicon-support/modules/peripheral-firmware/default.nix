{ config, pkgs, lib, ... }:
{
  config = lib.mkIf config.hardware.asahi.extractPeripheralFirmware {
    # Use sytemd-initrd as bootloader, because it is convenient to order stuff and will become default bootloader in the future
    boot.initrd.systemd.enable = true;
    boot.loader.systemd-boot.enable = true;
    # boot.loader.systemd-boot.configurationLimit = 5;
    # boot.loader.timeout = 3;

    # https://www.freedesktop.org/software/systemd/man/latest/bootup.html#Bootup%20in%20the%20initrd
    # when initrd-fs.target reached, ROOT is mounted to /sysroot and ESP to /sysroot/boot
    fileSystems."/boot".neededForBoot = true;

    boot.initrd.systemd.extraBin = {
      cpio = "${pkgs.cpio}/bin/cpio";
    };

    boot.initrd.systemd.services.asahi-vendor-firmware = {
      after = [ "initrd-fs.target" ];
      before = [ "initrd.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        [ -e /sysroot/lib/firmware ] && rm -rf /sysroot/lib/firmware
        mkdir -p /sysroot/lib/firmware  /tmp/.fwsetup/
        cd /tmp/.fwsetup/
        cat /sysroot/boot/vendorfw/firmware.cpio | cpio -id --quiet --no-absolute-filenames
        mv vendorfw/*  /sysroot/lib/firmware
        rm -rf /tmp/.fwsetup
      '';
      requiredBy = [ "initrd-fs.target" ];
    };
  };

  options.hardware.asahi = {
    extractPeripheralFirmware = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Automatically extract the non-free non-redistributable peripheral
        firmware necessary for features like Wi-Fi.
      '';
    };
  };
}
