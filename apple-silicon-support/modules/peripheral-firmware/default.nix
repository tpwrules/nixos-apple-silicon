{ config, pkgs, lib, ... }:
let
  pkgs' = config.hardware.asahi.pkgs;
in
{
  options.hardware.asahi.extractPeripheralFirmware = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Automatically extract the non-free non-redistributable peripheral
      firmware necessary for features like Wi-Fi.
    '';
  };

  config = lib.mkIf config.hardware.asahi.extractPeripheralFirmware (lib.mkMerge [
    {
      environment.systemPackages = [
        pkgs'.asahi-fwextract

        (pkgs.writeShellScriptBin "asahi-fwupdate" ''
          [ -e /boot/vendorfw.old ] && rm -rf /boot/vendorfw.old
          mv /boot/vendorfw /boot/vendorfw.old
          mkdir /boot/vendorfw
          asahi-fwextract /boot/asahi /boot/vendorfw
          echo "vendor firmware update success, please reboot"
        '')
      ];

      fileSystems."/boot".neededForBoot = true;
      fileSystems."/lib/firmware" = {
        device = "none";
        fsType = "tmpfs";
        options = [ "mode=755" ];
        neededForBoot = true;
      };
    }

    (lib.mkIf config.boot.initrd.systemd.enable {
      boot.initrd.systemd.extraBin = {
        cpio = "${pkgs.cpio}/bin/cpio";
      };

      boot.initrd.systemd.services.asahi-vendor-firmware = {
        after = [ "initrd-fs.target" ];
        before = [ "initrd.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir -p /tmp/.fwsetup/
          cd /tmp/.fwsetup/
          cat /sysroot/boot/vendorfw/firmware.cpio | cpio -id --quiet --no-absolute-filenames
          mv vendorfw/*  /sysroot/lib/firmware
          rm -rf /tmp/.fwsetup
        '';
        wantedBy = [ "initrd.target" ];
      };
    })

    (lib.mkIf (!config.boot.initrd.systemd.enable) {
      boot.initrd.postMountCommands = ''
        mkdir -p /tmp/.fwsetup/
        cd /tmp/.fwsetup/
        cat /mnt-root/boot/vendorfw/firmware.cpio | ${pkgs.cpio}/bin/cpio -id --quiet --no-absolute-filenames
        mv vendorfw/*  /mnt-root/lib/firmware
        rm -rf /tmp/.fwsetup
      '';
    })


  ]);
}
