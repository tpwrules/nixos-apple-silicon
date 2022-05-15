# UEFI Boot Standalone NixOS (2022-05-15)

This guide will build and was tested with the following software:
* Asahi Linux kernel, as of 2022-03-18
* m1n1, as of 2022-03-27
* Asahi Linux's U-Boot, as of 2022-03-19
* Nixpkgs, as of 2022-05-14
* macOS stub 12.3

NOTE: The latest version of this guide will always be [at its home](https://github.com/tpwrules/nixos-m1/blob/main/docs/uefi-standalone.md). For more general information about Linux on Apple Silicon Macs, refer to the [Asahi Linux project](https://asahilinux.org/) and [alpha installer release](https://asahilinux.org/2022/03/asahi-linux-alpha-release/).

## Introduction

This guide will explain how to install NixOS on the internal NVMe drive of an M1/Pro/Max Mac using a customized version of the official NixOS install ISO, then boot it without the help of another computer. Aside from the M1 support module and AArch64 CPU, the resulting installation can be configured and operated like any other NixOS system. Your macOS install will still work normally, and you can easily switch between booting both macOS and NixOS.

Perusing this guide might also be useful to users of other distros. Most of the hard work, including the kernel and boot software, was done by the [Asahi Linux project](https://asahilinux.org/).

#### Warning

Damage to the macOS recovery partitions or the partition table could result in the Mac becoming unbootable and loss of all data on the internal NVMe drive. In this circumstance, a suitable USB cable and another computer which can run [idevicerestore](https://github.com/libimobiledevice/idevicerestore) will be required to perform a DFU upgrade and restore normal operation. Backups are always wise.

While you will end up with a reasonably usable computer, the exact hardware features you want [may not be ready yet](https://github.com/AsahiLinux/docs/wiki/%22When-will-Asahi-Linux-be-done%3F%22). Please consult the [Asahi Linux Feature Support page](https://github.com/AsahiLinux/docs/wiki/Feature-Support) for information. Any features marked with a kernel version or `linux-asahi` should be supported by NixOS too.

#### Prerequisites

The following items are required to get started:
* M1/Pro/Max Mac (except Mac Studio) with macOS 12.3 or later and an admin account
* For Mac mini users: tested and working HDMI monitor. Many do not work properly; if it shows the Asahi Linux logo and console when m1n1 is running, it's fine.
* USB flash drive which is at least 512MB and can be fully erased, and USB A to C adapter
* Familiarity with the command line and installers without GUIs
* Optional: an x86_64 or aarch64 Linux PC or VM (any distro is fine)

#### Overview

* [Software Preparation](#software-preparation): build the customized NixOS installer ISO and Asahi Linux components
* [UEFI Preparation](#uefi-preparation): use the Asahi Linux installer to set up a standard UEFI boot environment
* [Installation](#installation): boot the NixOS installer and use it to set up and install NixOS
* [Maintenance](#maintenance): repair and upgrade NixOS and the Asahi Linux components
* [Removal](#removal): restore the system to the stock state


## Software Preparation

#### Nix

This setup takes advantage of the Nix package manager, which handles downloading and compiling everything. You must first install it on your Linux host PC if it doesn't run NixOS. Most distros are compatible, and installation (and uninstallation) is simple. Instructions are available on the [NixOS website](https://nixos.org/download.html#nix-quick-install).

If you cannot or do not wish to install Nix and/or build these components yourself, installation ISOs are automatically built and made available from the [GitHub Releases page](https://github.com/tpwrules/nixos-m1/releases). Download the latest one, use `dd` or similar to transfer it to your USB flash drive, then skip down to the section on [UEFI Preparation](#uefi-preparation). Programs like `unetbootin` are not supported. These ISOs are fully reproducible; that is, the ISO you download will be (or should be...) bit-identical to the one you will get by following these preparation instructions.

#### nixos-m1

Clone this repository to a suitable location on the host PC. In the future, you can update this repository using `git pull` and re-run the `nix-build` commands to update things.

```
$ git clone https://github.com/tpwrules/nixos-m1/
$ cd nixos-m1
```

#### m1n1

The Asahi Linux project has developed m1n1 as a bridge between Apple's boot firmware and the Linux world. m1n1 is installed as a faux macOS kernel into a stub macOS installation. In addition to booting Linux (or U-Boot), m1n1 also sets up the hardware and allows remote control and debugging over USB.

Change directories to the repository, then use Nix to build m1n1 and symlink the result to `m1n1`:

```
nixos-m1$ nix-build -A m1n1 -o m1n1
```

m1n1 has been built and the `.macho` and `.bin` files are now in `m1n1/build/`. You can also run m1n1's scripts such as `chainload.py` using a command like `m1n1/bin/m1n1-chainload`.

#### U-Boot

In the default installation, m1n1 loads U-Boot and U-Boot is used to set up a standard UEFI environment from which GRUB or systemd-boot or whatever can be booted. Due to the limitations of the Apple boot picker, there must be one EFI system partition per installed OS.

Use Nix to build U-Boot along with m1n1 and the device trees:

```
nixos-m1$ nix-build -A u-boot -o u-boot
```

The `.macho` and `.bin` files with m1n1, the device trees, and U-Boot joined together are now in `u-boot/`.

#### Kernel and Bootstrap Installer

The bootstrap NixOS installer ISO contains UEFI-compatible GRUB, the Asahi Linux kernel, its initrd, and enough packages and drivers to allow connection to the Internet in order to download and install a full NixOS system.

Building the image requires downloading of a large amount of data and compilation of a number of packages, including the kernel. On my six core Xeon laptop, building it took about 11 minutes (90 CPU minutes). Your mileage may vary. You can use the `-j` option to specify the number of packages to build in parallel. Each is allowed to use all cores, but for this build, most do not use more than one. Therefore, it is recommended to set it to less than the number of physical cores in your machine.

Use Nix to build the installer ISO (if you are on an aarch64 machine, use `installer-bootstrap` instead of `installer-bootstrap-cross`):

```
nixos-m1$ nix-build -A installer-bootstrap-cross -o installer -j4
```

The installer ISO is now available in `installer/iso/nixos-22.05pre-git-aarch64-linux.iso`. Use `dd` or similar to transfer it to your USB flash drive. Programs like `unetbootin` are not supported.

## UEFI Preparation

This setup uses the alpha Asahi Linux installer to install a stub macOS and standard UEFI boot environment from which the NixOS installer and installed OS will run. These steps must be run from Terminal.app in macOS. You must also be logged into an administrator account.

#### Asahi Linux Installation

Download and run the alpha installer with the following command:
```
% curl https://alx.sh | sh
```

Choose the following options to get started:
* Enter your administrator password
* Do not enable expert mode

Resize your existing macOS install:
* Resize an existing partition to make space for a new OS (`r`)
* Enter the new size of the macOS install. It should be at least 20GB less than its current size to make room for NixOS with a GUI (note that here 1GB = 1,000,000,000 bytes)
* Confirm the resize operation
* Wait patiently while the partition is resized; it will take several minutes. Do not attempt to use the machine while this is in progress.
* Press enter when finished

Install UEFI environment:
* Install an OS into free space (`f`)
* UEFI environment only
* Name it NixOS (this is what shows up in the firmware boot picker)
* Wait while the installation proceeds and enter your password when prompted
* Wait for the default boot volume to be set (this may take several seconds)
* Read the final advice, then press enter to shut down the machine

Boot into recovery mode by holding the power button down as directed and select the new NixOS option in the boot picker. Follow the prompts and enter your administrator password. The local policy update will take several seconds to complete. Once complete, select that you want to set a custom boot object and put your system to permissive security mode, enter your administrator username (the same one you put in the password for earlier) and password, then reboot when prompted.

If everything went well, you will restart into U-Boot with the Asahi Linux and U-Boot logos on-screen. Shut the system down by holding the power button, then proceed to the next step.

## Installation

#### Booting the Installer

Shut down the machine fully. Connect the flash drive with the installer ISO to a USB-C port through the USB A to C adapter. If on a Mac mini, you must use the USB-C ports as U-Boot does not support the USB-A ports at this time. If not using Wi-Fi, connect the Ethernet cable to the network port or adapter as well.

Start the Mac, and U-Boot should start booting from the USB drive automatically. If you've already installed something to the internal NVMe drive, U-Boot will try to boot it first. To instead boot from USB, hit a key to stop autoboot when prompted, then run the command `run bootcmd_usb0`.

GRUB will start, then the NixOS installer after a short delay (the default GRUB option is fine). You will get a console prompt once booting completes. Run the command `sudo su` to get a root prompt in the installer. If the console font is too small, run the command `setfont ter-v32n` to increase the size.


#### Partitioning and Formatting

**DANGER: Damage to the GPT partition table, first partition (`iBootSystemContainer`), or the last partition (`RecoveryOSContainer`) could result in the loss of all data and render the Mac unbootable and unrecoverable without assistance from another computer! Do not use your distro's automated partitioner or partitioning instructions!**

We will add a root partition to the remaining free space and format it as ext4. Alternative partition layouts and filesystems, including LUKS encryption, are possible, but not covered by this guide.

Create the root partition to fill up the free space:
```
nixos# sgdisk /dev/nvme0n1 -n 0:0 -s
[...]
The operation has completed successfully.
```

Identify the number of the new root partition (type code 8300, typically second to last):
```
nixos# sgdisk /dev/nvme0n1 -p
Disk /dev/nvme0n1: 244276265 sectors, 931.8 GiB
Model: APPLE SSD AP1024Q                       
Sector size (logical/physical): 4096/4096 bytes
Disk identifier (GUID): 27054D2E-307A-41AA-9A8C-3864D56FAF6B
Partition table holds up to 128 entries
Main partition table begins at sector 2 and ends at sector 5
First usable sector is 6, last usable sector is 244276259
Partitions will be aligned on 1-sector boundaries
Total free space is 0 sectors (0 bytes)

Number  Start (sector)    End (sector)  Size       Code  Name
   1               6          128005   500.0 MiB   FFFF  iBootSystemContainer
   2          128006       219854567   838.2 GiB   AF0A  Container
   3       219854568       220465127   2.3 GiB     AF0A  
   4       220465128       220590311   489.0 MiB   EF00  
   5       220590312       242965550   85.4 GiB    8300  
   6       242965551       244276259   5.0 GiB     FFFF  RecoveryOSContainer
```

Format the new root partition:
```
nixos# mkfs.ext4 -L nixos /dev/nvme0n1p5
```

#### NixOS Configuration

The subsequent steps in this section will help you install NixOS onto your new partitions. More information is available in the Installing section of the [NixOS manual](https://nixos.org/manual/nixos/stable/index.html#sec-installation-installing). Some changes to the configuration procedure as described in that manual are needed for NixOS on M1 to work properly.

Mount the root partition, then the EFI system partition that was created by the Asahi Linux installer specifically for NixOS:
```
nixos# mount /dev/disk/by-label/nixos /mnt
nixos# mkdir -p /mnt/boot
nixos# mount /dev/disk/by-partuuid/`cat /proc/device-tree/chosen/asahi,efi-system-partition` /mnt/boot
```

Create a default configuration for the new system, then copy the M1 support module and system WiFi firmware into it:
```
nixos# nixos-generate-config --root /mnt
nixos# cp -r /etc/nixos/m1-support /mnt/etc/nixos/
nixos# cp /mnt/boot/vendorfw/firmware.tar /mnt/etc/nixos/m1-support/firmware/
nixos# chmod -R +w /mnt/etc/nixos/
```

Use Nano to edit the configuration of the new system to include the M1 support module. Be aware that other editors and most documentation has been left out of the bootstrap installer to save space and time.
```
nixos# nano /mnt/etc/nixos/configuration.nix
```

Add the `./m1-support` directory to the imports list and switch off the `canTouchEfiVariables` option. That portion of the file should look like this:
```
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Include the necessary packages and configuration for Apple M1 support.
      ./m1-support
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
```

If you used the cross-compiled installer image, i.e. you downloaded the ISO from GitHub or built `installer-bootstrap-cross`, add the following line to re-use the cross-compiled kernel. If you don't, the kernel will be rebuilt in the installer, which wastes time. If at any point you change the kernel configuration or update the system, and the kernel needs to be rebuilt on the Mac itself, remove this line or you will get an error that an `x86_64-linux` builder is required.
```
  # Remove if you get an error that an x86_64-linux builder is required.
  boot.kernelBuildIsCross = true;
```

The configuration above is the minimum required to produce a bootable system, but you can further edit the file as desired to perform additional configuration. Uncomment the relevant options and change their values as explained in the file. Note that some advertised features may not work properly at this time. Refer to the [NixOS installation manual](https://nixos.org/manual/nixos/stable/index.html#ch-configuration) for further guidance.

You can optionally choose to build the Asahi kernel with a 4K page size by enabling the appropriate option. This results in a reduction in compilation speed of 10-25%, but improves software compatibility in some cases (such as with Chromium/Electron and x86 emulation).
```
  # Build the kernel with 4K pages to improve software compatibility at
  # the cost of performance in some cases.
  boot.kernelBuildIs16K = false;
```

If you want to install a desktop environment, you will have to uncomment the option to enable X11 and NetworkManager, then add an option to include your favorite desktop environment. You may also wish to include graphical packages such as `firefox` in `environment.systemPackages`. For example, to install Xfce:
```
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
```

#### NixOS Installation

Once you are happy with your initial configuration, you may install the system. This will have to download a large amount of data.

If using WiFi, the WiFi firmare must first be installed into the live system:
```
nixos# mkdir -p /lib/firmware
nixos# tar xf /mnt/boot/vendorfw/firmware.tar -C /lib/firmware
nixos# systemctl start wpa_supplicant
nixos# rmmod brcmfmac && modprobe brcmfmac
```

You can now configure wireless networking in the installer using `wpa_supplicant` by following [the directions](https://nixos.org/manual/nixos/stable/index.html#sec-installation-booting-networking) in the NixOS manual. If you see errors about `Timeout on response for query command`, exit `wpa_cli` then try rerunning the command `rmmod brcmfmac && modprobe brcmfmac`.

Once the network is set up, ensure the time is set correctly, then install the system. You will be asked to set a root password as the final step:
```
nixos# systemctl restart systemd-timesyncd
nixos# nixos-install
[...]
setting root password...
New password: ***
Retype new password: ***
passwd: password updated successfully
installation finished!
```

If there are any errors, or you mess up entering the root password, you can edit the configuration and safely re-run the command.

Once complete, reboot the system:
```
nixos# reboot
```

When the system reboots, the bootloader will come up and boot the default configuration after a short delay. Once NixOS boots, log in with the root password, and create your account, or set your user account password if you created your account in the configuration. To learn more about NixOS's configuration system, read the section in the manual on [changing the configuration](https://nixos.org/manual/nixos/stable/index.html#sec-changing-config).

#### Dual Booting

The machine is now set up to boot NixOS by default when turned on. To access the boot picker, turn off the machine, then hold the power button to turn the machine on instead of just pressing it. Let go once the options come up. To boot a particular OS once, click on it, then click Continue underneath it. To switch the default OS, click on the desired default, hold Option (Alt), then click Always Use underneath it.

#### Hypervisor Boot

By selecting the appropriate menu option in the Asahi Linux installer, you can also choose to install m1n1 without U-Boot and run U-Boot, the bootloader, and the OS under m1n1's hypervisor.

To run U-Boot under the hypervisor, start m1n1 and attach the Mac to the host PC using an appropriate USB cable, change directories to the repo, then run:

```
nixos-m1$ m1n1/bin/m1n1-run_guest u-boot/m1n1-u-boot.macho
```

To access the serial console, in a separate terminal run:

```
$ nix-shell -p picocom --run 'picocom /dev/ttyACM1'
```

Downloading the kernel over USB using m1n1 is not supported.

## Maintenance

#### Rescue

If something goes wrong and NixOS doesn't boot or is otherwise unusable, you can first try rolling back to a previous generation. Instead of selecting the default bootloader option, choose another configuration that worked previously.

If something is seriously wrong and the bootloader does not work (or you don't have any other generations), you will want to get back into the installer. To start the installer with a system installed on the internal disk, shut down the computer, re-insert the USB drive with the installer, start it up again, hit a key in U-Boot when prompted to stop autoboot, then run the command `run bootcmd_usb0`.

Once in the installer, you can re-mount your root partition and EFI system partition without reformatting them. Depending on what exactly went wrong, you might need to edit your configuration, copy over the latest M1 support module, or update U-Boot using the latest installer.

Rerunning the installer will create a new generation but not touch any user data. This means you can "undo" the installation by selecting a previous generation in the bootloader. To redo the installation without changing your root password or changing the version of Nixpkgs, run:
```
# nixos-install --no-root-password --no-channel-copy
```

In extreme circumstances, you can delete the EFI system partition and stub macOS install and rerun the Asahi Linux installer, then follow the steps above to reinstall NixOS's bootloader menu. You will need to regenerate the hardware configuration using `nixos-generate-config --root /mnt` because the EFI system partition's ID will change. This shouldn't modify your root partition or other NixOS configuration, but of course it's always smart to have a backup.

#### NixOS Updates

NixOS itself can be updated like any other NixOS system. In brief, this is as follows:
```
$ sudo nix-channel --update
$ sudo nixos-rebuild switch
```

You may have to reboot after updating in some cases. If something goes wrong, you can boot a previous generation and roll back the channel update. For more details, consult the [Upgrading section](https://nixos.org/manual/nixos/stable/index.html#sec-upgrading) of the NixOS manual.

#### M1 Support Updates

To update the M1 support module, including the Asahi kernel, U-Boot, and m1n1, you can simply download newer files from this repo under `nix/m1-support` and place them under `/etc/nixos/m1-support`. Any changes will require a configuration rebuild and reboot to take effect. If you wish to customize your kernel, you can edit the kernel config in `/etc/nixos/m1-support/kernel/config`. Consult the comments in `/etc/nixos/m1-support/kernel/default.nix` and `/etc/nixos/m1-support/kernel/package.nix` for more details. Note that if the kernel device trees change, U-Boot will need to be updated too.

U-Boot and m1n1 are automatically managed by NixOS' bootloader system. If you roll back to a previous generation and things do not work properly due to a device tree incompatibility, you can run `/run/current-system/bin/switch-to-configuration switch` then reboot to force the bootloader and the correct version of U-Boot/m1n1 to be reinstalled and loaded.

If you want the M1 support module to be upgraded in tandem with NixOS instead of manually downloading new files, you can add it as a channel with the following command:
```
$ sudo nix-channel --add https://github.com/tpwrules/nixos-m1/archive/main.tar.gz m1-support
```

Modify your `/etc/nixos/configuration.nix` to reference the channel instead of the local files (although we will keep referencing the local firmware):
```
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Include the necessary packages and configuration for Apple M1 support.
      <m1-support/nix/m1-support>
      # Include the non-redistributable Wi-Fi firmware on disk.
      ./m1-support/firmware
    ];
```

You can now update NixOS as normal. Note that M1 support module updates will generally require reboots to load new kernels and other boot components:
```
$ sudo nix-channel --update
$ sudo nixos-rebuild switch
$ sudo reboot
```

## Removal

#### Host PC Cleanup

To recover the space on the host PC, change directories into the repo, remove the built symlinks (removing just the installer will recover almost all the space), then run the garbage collector:

```
nixos-m1$ rm m1n1 u-boot installer result
nixos-m1$ nix-collect-garbage
```

#### NixOS Uninstallation

NixOS can be completely uninstalled by deleting the stub partition, EFI system partition, and root partition off the disk.

Boot back into macOS by shutting down the machine fully, then pressing and holding the power button until the boot picker comes up. Select the macOS installation, then click Continue to boot it. Log into an administrator account and open Terminal.app.

Identify the partitions to remove. In this example, `disk0s3` is the stub because of its small size. `disk0s4` is the EFI system partition and `disk0s5` is the root partition:
```
% diskutil list disk0
/dev/disk0 (internal):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                         1.0 TB     disk0
   1:             Apple_APFS_ISC                         524.3 MB   disk0s1
   2:                 Apple_APFS Container disk4         900.0 GB   disk0s2
   3:                 Apple_APFS Container disk3         2.5 GB     disk0s3
   4:                        EFI EFI - NIXOS             512.8 MB   disk0s4
   5:           Linux Filesystem                         91.6 GB    disk0s5
   6:        Apple_APFS_Recovery                         5.4 GB     disk0s6
```

WARNING: Unlike Linux, on macOS each partition's identifier does not necessarily equal its partition index. Double check the identifiers of your own system!

Remove the EFI system partition and root partition:
```
% diskutil eraseVolume free free disk0s4
Started erase on disk0s4 (EFI - NIXOS)
Unmounting disk
Finished erase on disk0
% diskutil eraseVolume free free disk0s5
Started erase on disk0s5
Unmounting disk
Finished erase on disk0
```

Remove the stub partition:
```
% diskutil apfs deleteContainer disk0s3
Started APFS operation on disk3
Deleting APFS Container with all of its APFS Volumes
[...]
Removing disk0s3 from partition map
```

Expand the main macOS partition to use the resulting free space. This command will take a few minutes to run; do not attempt to use the machine while it is in progress:
```
% diskutil apfs resizeContainer disk0s2 0
Started APFS operation
Aligning grow delta to 94,662,586,368 bytes and targeting a new physical store size of 994,662,584,320 bytes
[...]
Finished APFS operation
```

To complete the uninstallation, open the Startup Disk pane of System Preferences and select your macOS installation as the startup disk. If this is not done, the next boot will fail, and you will be asked to select another OS to boot from.
