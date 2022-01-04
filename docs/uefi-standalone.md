# UEFI Boot Standalone NixOS (2022-01-04)

THIS IS PROBABLY ALREADY OUT OF DATE! If it's been more than a week since the date above, there's definitely a better way to do this.

This guide will build and was tested with the following software:
* Asahi Linux kernel, as of 2021-12-15
* m1n1, as of 2022-01-03
* Mark Kettenis' U-Boot, as of 2022-01-02
* Nixpkgs, as of 2021-12-14
* macOS stub 11.4

## Introduction

This guide will explain how to install NixOS on the internal NVMe drive of an M1 Mac (M1 Pro/Max are not supported at this time) using a customized version of the official installer, then boot it using GRUB without the help of another computer. If you like, you can use another distro's installer (although to my knowledge none are compatible yet); the NixOS specific steps are marked.

The process of preparing the Mac for installation of Linux is currently in flux, and will not be described here. If you want to follow this guide, you should already have a working m1n1 install which can display stuff on your screen and you can interact with over USB. Additionally, you should have created a blank partition on the internal NVMe drive separate from the macOS stub partition which is at least 5GB (10GB for full GUI).

## Warning

Damage to the macOS recovery partitions or the partition table could result in the Mac becoming unbootable and loss of all data on the internal NVMe drive. In this circumstance, a suitable USB cable and another computer which can run [idevicerestore](https://github.com/libimobiledevice/idevicerestore) will be required to perform a DFU upgrade and restore normal operation.

This also does not necessarily promise to be useful. Just because you can do it doesn't mean you should. A lot of features are currently missing, and this guide has only been tested on an M1 Mac mini. But, it is pretty cool.

## Prerequisites

The following items are required to get started:
* M1 Mac with working m1n1 setup (M1 Pro/Max are not supported by U-Boot yet) and a blank partition, separate from the macOS stub partition, which is at least 5GB (10GB for full GUI)
* For Mac mini users: tested and working HDMI monitor. Many do not work properly; if it shows the Asahi Linux logo and console when m1n1 is running, it's fine. Note that HDMI is at this time broken completely if the stub partition has macOS 12.0.1 or newer.
* Ethernet cable (WiFi drivers are not incorporated yet)
* USB flash drive which is at least 512MB and can be fully erased
* For laptop users: USB to Ethernet adapter, USB A to C adapter, and hub
* An x86_64 or aarch64 Linux PC or VM (any distro is fine) on the same network as the Mac
* Familiarity with the command line and installers without GUIs

## Software Preparation

#### Nix

This setup takes advantage of the Nix package manager, which handles downloading and compiling everything. You must first install it on your Linux host PC if it doesn't run NixOS. Most distros are compatible, and installation (and uninstallation) is simple. Instructions are available on the [NixOS website](https://nixos.org/download.html#nix-quick-install).

#### nixos-m1

Clone this repository to a suitable location on the host PC. In the future, you can update this repository using `git pull` and re-run the `nix-build` commands to update things.

```
$ git clone https://github.com/tpwrules/nixos-m1/
$ cd nixos-m1
```

#### m1n1

Change directories to the repository, then use Nix to build m1n1 and symlink the result to `m1n1`:

```
nixos-m1$ nix-build -A m1n1 -o m1n1
```

m1n1 has been built and the `.macho` and `.bin` files are now in `m1n1/build/`. You can also run m1n1's scripts such as `chainload.py` using a command like `m1n1/bin/m1n1-chainload`.

#### U-Boot

U-Boot depends on a device tree specific to each model of Mac. The list of models is available in the [Asahi documentation](https://github.com/AsahiLinux/docs/wiki/Devices). For example, the Mac mini has SOC T8103 and Product J274AP. This means its device tree is `t8103-j274`.

Use Nix to build U-Boot along with m1n1 and the device tree for your Mac. This command builds a U-Boot with the Mac mini device tree:

```
nixos-m1$ nix-build -A u-boot.t8103-j274 -o u-boot
```

The `.macho` and `.bin` files with m1n1, the device tree, and U-Boot joined together are now in `u-boot/`.

#### Kernel and Bootstrap Installer

The bootstrap NixOS installer ISO contains UEFI-compatible GRUB, the Asahi Linux kernel, its initrd, and enough packages and drivers to allow connection to the internet in order to download and install a full NixOS system. If you prefer, you can use the installer ISO of another distro, as long as it is UEFI bootable and has a compatible kernel.

Building the image requires downloading of a large amount of data and compilation of a number of packages, including the kernel. On my six core Xeon laptop, building it took about 11 minutes (90 CPU minutes). Your mileage may vary. You can use the `-j` option to specify the number of packages to build in parallel. Each is allowed to use all cores, but for this build, most do not use more than one. Therefore, it is recommended to set it to less than the number of physical cores in your machine.

Use Nix to build the installer ISO (if you are on an aarch64 machine, use `installer-bootstrap` instead of `installer-bootstrap-cross`):

```
nixos-m1$ nix-build -A installer-bootstrap-cross -o installer -j4
```

The installer ISO is now available in `installer/iso/nixos-22.05pre-git-aarch64-linux.iso`. Use `dd` or similar to transfer it to your USB flash drive. Programs like `unetbootin` are not supported.

## Installation

#### U-Boot

Figure out the IP of the host Linux PC where you built everything (using e.g. `ip addr`). On that PC, change directories into the git repo and start an HTTP server for the Mac to download the files from:

```
nixos-m1$ nix-shell -p python3 --run 'python3 -m http.server'
```

Boot the Mac into 1TR and open the Terminal. Download the U-Boot image (replacing `.macho` with `.bin` if appropriate) from the host PC:

```
# curl http://<host PC IP>:8000/u-boot/u-boot.macho -o u-boot.macho
```

Use `kmutil` to install the `.macho` or `.bin` according to the [m1n1 manual](https://github.com/AsahiLinux/m1n1#usage), depending on your system.

```
# kmutil configure-boot -c u-boot.macho <...>
```

Once `kmutil` has completed successfully, shut down the machine. If on a laptop, connect your USB peripherals, including the flash drive with the installer ISO, to a USB-C port through the USB A to C adapter. If on a Mac mini, you can use either the USB-A or USB-C ports. Connect the Ethernet cable to the network port or adapter as well.

Start the Mac, and U-Boot should start booting from the USB drive. After a short delay, GRUB will start, then the NixOS installer (the default GRUB option is fine). You will get a console prompt once booting completes.

If you've already installed something to the internal NVMe drive, U-Boot will try to boot it first. To instead boot from USB, hit a key to stop autoboot when prompted, then run the command `run usb_boot`.

#### Partitioning and Formatting

**DANGER: Damage to the GPT partition table, first partition (`iBootSystemContainer`), or the last partition (`RecoveryOSContainer`) could result in the loss of all data and render the Mac unbootable and unrecoverable without assistance from another computer! Do not use your distro's automated partitioner or partitioning instructions!**

We will partition the internal NVMe drive to add an EFI system partition for GRUB and a root partition for Linux while preserving the correct layout of the existing partitions. Use of alternative partition layouts is possible, though not recommended at this time.

We will use `gdisk` here so make sure your distro's installer has it; `parted` is not recommended. Below is an example transcript of the partitioning process, with the commands you need to enter and `gdisk`'s replies. Commands you should enter are _italicized_. Comments on those commands or on `gdisk`'s output are **(bold and in parentheses)**; do not type them in. Please read through it and understand what is going on before you start, bearing in mind that your disk may be slightly different.

<pre>
nixos$ <i>sudo gdisk /dev/nvme0n1</i>
GPT fdisk (gdisk) version 1.0.8

<p>
Partition table scan:
  MBR: protective
  BSD: not present
  APM: not present
  GPT: present
</p>

Found valid GPT with protective MBR; using GPT.

Command (? for help): <i>p</i> <b>(print the existing partition table and verify it roughly matches this layout)</b>
Disk /dev/nvme0n1: 244276265 sectors, 931.8 GiB
Model: APPLE SSD AP1024Q                       
Sector size (logical/physical): 4096/4096 bytes
Disk identifier (GUID): (...)
Partition table holds up to 128 entries
Main partition table begins at sector 2 and ends at sector 5
First usable sector is 6, last usable sector is 244276259
Partitions will be aligned on 1-sector boundaries
Total free space is 162 sectors (648.0 KiB)

<b>(save this printout using e.g. a picture of your screen for future reference if something goes wrong)</b>
Number  Start (sector)    End (sector)  Size       Code  Name
   1               6          128005   500.0 MiB   FFFF  iBootSystemContainer <b>(DO NOT TOUCH)</b>
   2          128006       122198317   465.7 GiB   AF0A  Container  <b>(macOS partition with all your files)</b>
   3       122198318       123419020   4.7 GiB     AF0A  <b>(macOS stub partition for m1n1)</b>
   4       123419136       242965503   456.0 GiB   0700  <b>(blank partition we will install Linux to)</b>
   5       242965551       244276259   5.0 GiB     FFFF  RecoveryOSContainer <b>(DO NOT TOUCH)</b>

<b>(skip this command if there is no blank partition but instead free space)</b>
Command (? for help): <i>d</i> <b>(delete the blank Linux partition)</b>
Partition number (1-5): <i>4</i> <b>(which is number four on this disk)</b>

Command (? for help): <i>n</i> <b>(create new EFI system partition)</b>
Partition number (4-128, default 4):  <b>(hit Enter to accept default)</b>
First sector (123419021-242965550, default = 123419021) or {+-}size{KMGTP}:  <b>(hit Enter to accept default)</b> 
Last sector (123419021-242965550, default = 242965550) or {+-}size{KMGTP}: <i>+512M</i> <b>(should not be smaller)</b>
Current type is 8300 (Linux filesystem)
Hex code or GUID (L to show codes, Enter = 8300): <i>EF00</i> <b>(EFI system partition code)</b>
Changed type of partition to 'EFI system partition'

Command (? for help): <i>n</i> <b>(create the root partition)</b>
Partition number (6-128, default 6):  <b>(hit Enter to accept default)</b>
First sector (123550093-242965550, default = 123550093) or {+-}size{KMGTP}:  <b>(hit Enter to accept default)</b>
Last sector (123550093-242965550, default = 242965550) or {+-}size{KMGTP}:  <b>(hit Enter to accept default)</b>
Current type is 8300 (Linux filesystem)
Hex code or GUID (L to show codes, Enter = 8300):  <b>(hit Enter to accept default)</b>
Changed type of partition to 'Linux filesystem'

Command (? for help): <i>s</i> <b>(sort the partition table so the recovery partitions are placed correctly)</b>
You may need to edit /etc/fstab and/or your boot loader configuration!

Command (? for help): <i>p</i> <b>(print the new partition table and verify it roughly matches this layout)</b>
Disk /dev/nvme0n1: 244276265 sectors, 931.8 GiB
Model: APPLE SSD AP1024Q                       
Sector size (logical/physical): 4096/4096 bytes
Disk identifier (GUID): (...)
Partition table holds up to 128 entries
Main partition table begins at sector 2 and ends at sector 5
First usable sector is 6, last usable sector is 244276259
Partitions will be aligned on 1-sector boundaries
Total free space is 0 sectors (0 bytes)

<b>(verify that the information for the "not touched" partitions did not change from the first printout)</b>
<b>(if it changed or something doesn't look right, type <i>q</i> to exit the partitioner without saving changes)</b>
Number  Start (sector)    End (sector)  Size       Code  Name
   1               6          128005   500.0 MiB   FFFF  iBootSystemContainer <b>(was not touched)</b>
   2          128006       122198317   465.7 GiB   AF0A  Container <b>(was not touched)</b>
   3       122198318       123419020   4.7 GiB     AF0A  <b>(was not touched)</b>
   4       123419021       123550092   512.0 MiB   EF00  EFI system partition <b>(new EFI system partition)</b>
   5       123550093       242965550   455.5 GiB   8300  Linux filesystem <b>(new root partition)</b>
   6       242965551       244276259   5.0 GiB     FFFF  RecoveryOSContainer <b>(was not touched)</b>

Command (? for help): <i>w</i> <b>(write the new layout to disk)</b>

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): <i>y</i>
OK; writing new GUID partition table (GPT) to /dev/nvme0n1.
The operation has completed successfully.
</pre>

After partitioning the disk, you should now have an EFI system partition which we will call `/dev/nvme0n1pX` (`/dev/nvme0n1p4` in the above example) and a root partition which we will call `/dev/nvme0n1pY` (`/dev/nvme0n1p5` in the above example).

Format the EFI system partition as FAT32 and root partition as ext4:

```
nixos$ sudo mkfs.vfat -F 32 -s 1 -n boot /dev/nvme0n1pX
nixos$ sudo mkfs.ext4 -L nixos /dev/nvme0n1pY
```

Use your distro's installation instructions to install GRUB to the EFI system partition and the main OS to the root partition. You will have to install GRUB to the fallback location `/efi/boot/bootaa64.efi` on the EFI system partition by passing the `--removable` flag to `grub-install` as U-Boot does not support EFI variables.

Installation of NixOS, and GRUB using NixOS's mechanisms, is covered below.

#### NixOS Installation

The subsequent steps in this section will help you install NixOS onto your new partitions. More information is available in the Installing section of the [NixOS manual](https://nixos.org/manual/nixos/stable/index.html#sec-installation-installing). Some changes to the configuration as described in that manual are needed for NixOS on M1 to work properly.

Mount the new partitions:

```
nixos$ sudo mount /dev/disk/by-label/nixos /mnt
nixos$ sudo mkdir -p /mnt/boot
nixos$ sudo mount /dev/disk/by-label/boot /mnt/boot
```

Create a default configuration for the new system, then copy the Asahi Linux kernel configuration module to it:

```
nixos$ sudo nixos-generate-config --root /mnt
nixos$ sudo cp -r /etc/nixos/kernel /mnt/etc/nixos/
nixos$ sudo chmod -R +w /mnt/etc/nixos/
```

Use Nano to edit the configuration of the new system to include the kernel module and GRUB bootloader. Be aware that other editors and most documentation has been left out of the bootstrap installer to save space and time.

```
nixos$ sudo nano /mnt/etc/nixos/configuration.nix
```

Add the `./kernel` directory to the imports list, remove the three lines that mention `systemd-boot`, and set the relevant options to enable GRUB. That portion of the file should look like this:

```
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Include the Asahi Linux kernel module and relevant configuration.
      ./kernel
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    version = 2;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.loader.efi.canTouchEfiVariables = false;
```

If you used the cross-compiled installer image, i.e. you built `installer-bootstrap-cross`, add the following line to re-use the cross-compiled kernel. If you don't, the kernel will be rebuilt in the installer, which wastes time. If at any point you change the kernel configuration or update the system, and the kernel needs to be rebuilt on the Mac itself, remove this line or you will get an error that an `x86_64-linux` builder is required.

```
  # Remove if you get an error that an x86_64-linux builder is required.
  boot.kernelBuildIsCross = true;
```

The configuration above is the minimum required to produce a bootable system, but you can further edit the file as desired to perform additional configuration. Uncomment the relevant options and change their values as explained in the file. Note that several advertised features, including WiFi, sound, and the firewall, do not work properly at this time. Refer to the [NixOS installation manual](https://nixos.org/manual/nixos/stable/index.html#ch-configuration) for further guidance.

If you want to install a desktop environment, you will have to uncomment the option to enable X11 and add an option to include your favorite desktop environment. You may also wish to include graphical packages such as `firefox` in `environment.systemPackages`. For example, to install Xfce:

```
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
```

Once you are happy with your initial configuration, install the system. This will also have to download a large amount of data. If there are SSL errors, wait a minute or so for the time to be set correctly over the network. If there are any other errors, you can edit the configuration and safely re-run the command. You will be asked to set a root password as the final step. If this fails (for example if you type the password incorrectly), you can still re-run the command safely. Once complete, you can reboot the system.

```
nixos$ sudo nixos-install
[...]
setting root password...
New password: ***
Retype new password: ***
passwd: password updated successfully
installation finished!

nixos$ sudo reboot
```

Note that shutting down from Linux currently does not work at all; you will have to manually hold the power button until the computer shuts off after you've issued the command. However, rebooting works properly.

#### Using NixOS

When the system reboots, GRUB will come up and boot the default configuration after a short delay, which is the one you've most recently built. You can also select and boot older configurations under the "All configurations" submenu.

If the system does not boot or is otherwise unusable, for example if the network was not configured correctly, you will need to get back into the installer. To start the installer with a system installed on the internal disk, shut down the computer, re-insert the USB drive with the installer, start it up again, hit a key in U-Boot when prompted to stop autoboot, then run the command `run usb_boot`. You can then re-mount your partitions (reformatting them is unnecessary), edit the configuration, and reinstall it.

Once the system boots, log in with the root password, and create your account or set your user account password. To learn more about NixOS's configuration system, read the section in the manual on [changing the configuration](https://nixos.org/manual/nixos/stable/index.html#sec-changing-config).

To update the Asahi kernel, you can download newer files under `nix/kernel` from this repo and place them under `/etc/nixos/kernel`. Alternately, you can edit the kernel config in `/etc/nixos/kernel/config`. Consult the comments in `/etc/nixos/kernel/default.nix` and `/etc/nixos/kernel/package.nix` for more details. Any changes will require a configuration rebuild to take effect. Note that if the kernel device trees change, U-Boot will need to be updated and reinstalled.

#### Hypervisor Boot

You can also choose to install m1n1 without U-Boot and run U-Boot, GRUB and the OS under m1n1's hypervisor. To do this, instead download `m1n1/build/m1n1.macho` (or `.bin`) and install it using `kmutil`.

To run U-Boot under the hypervisor, start m1n1 and attach the Mac to the host PC using an appropriate USB cable, change directories to the repo, then run:

```
nixos-m1$ m1n1/bin/m1n1-run_guest u-boot/u-boot.macho
```

To access the serial console, in a separate terminal run:

```
$ nix-shell -p picocom --run 'picocom /dev/ttyACM1'
```

Downloading the kernel over USB using m1n1 is not supported.

#### Cleanup

To recover the space on the host PC, change directories into the repo, remove the built symlinks (removing just the installer will recover almost all the space), then run the garbage collector:

```
nixos-m1$ rm m1n1 u-boot installer result
nixos-m1$ nix-collect-garbage
```

To remove NixOS from the Mac, just delete the EFI system and root partitions (taking care to not touch the recovery partitions) and reinstall m1n1 using `kmutil`.
