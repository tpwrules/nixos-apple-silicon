# Quick and Dirty Standalone NixOS

This guide will explain how to install NixOS on the internal NVMe drive of an M1 Mac (M1 Pro/Max are not supported at this time), then boot it without the help of another computer. The process of preparing the Mac for installation of Linux is currently in flux, and will not be described here. If you want to follow this guide, you should already have a working m1n1 install which can display stuff on your screen and you can interact with over USB. Additionally, you should have created a blank partition on the internal NVMe drive separate from the macOS stub partition which is at least 5GB (10GB for full GUI).

## Warning

Damage to the macOS recovery partitions or the partition table could result in the Mac becoming unbootable and loss of all data on the internal NVMe drive. In this circumstance, a suitable USB cable and another computer which can run [idevicerestore](https://github.com/libimobiledevice/idevicerestore) will be required to perform a DFU upgrade and restore normal operation.

This also does not necessarily promise to be useful. Just because you can do it doesn't mean you should. A lot of features are currently missing, and this guide has only been tested on an M1 Mac mini. But, it is pretty cool.

## Prerequisites

The following items are required to get started:
* M1 Mac with working m1n1 setup (M1 Pro/Max are not supported by U-Boot yet) and a blank partition, separate from the macOS stub partition, which is at least 5GB (10GB for full GUI)
* For Mac mini users: tested and working HDMI monitor. Many do not work properly; if it shows the Asahi Linux logo and console when m1n1 is running, it's fine. Note that HDMI is at this time broken completely if the stub partition has a macOS newer than 11.4.
* Ethernet cable (WiFi drivers are not incorporated yet)
* USB keyboard and mouse (internal keyboards are not supported by U-Boot yet, and may not work in Linux at the moment)
* For laptop users: USB to Ethernet adapter, USB A to C adapter, and hub
* An x86_64 Linux PC (any distro is fine) on the same network as the Mac
* Familiarity with the command line and installers without GUIs

## Software Preparation

#### Nix

This setup takes advantage of the Nix package manager, which handles downloading and compiling everything. You must first install it on your Linux host PC if it doesn't run NixOS. Most distros are compatible, and installation (and uninstallation) is simple. Instructions are available on the [NixOS website](https://nixos.org/download.html#nix-quick-install).

#### nixos-m1

Clone the repository to a suitable location on the host PC. In the future, you can update this repository and re-run the `nix-build` commands to update things.

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

U-Boot depends on a device tree specific to each type of Mac. The list of devices is available in the [Asahi documentation](https://github.com/AsahiLinux/docs/wiki/Devices). For example, the Mac mini has SOC T8103 and Product J274AP. This means its device tree is `t8103-j274`.

Use Nix to build U-Boot along with m1n1 and the device tree for your Mac. This command builds a U-Boot with the Mac mini device tree:

```
nixos-m1$ nix-build -A u-boot.t8103-j274 -o u-boot
```

The `.macho` and `.bin` files with m1n1, the device tree, and U-Boot joined together are now in `u-boot/`.

#### Kernel and Bootstrap Root Filesystem

The bootstrap root filesystem image contains the Asahi Linux kernel, initrd, and enough packages and drivers to allow connection to the internet in order to download and install a full NixOS system.

Building the image requires downloading of a large amount of data and compilation of a number of packages, including the kernel. On my six core Xeon laptop, building it took about 8 minutes (61 CPU minutes). Your mileage may vary. You can use the `-j` option to specify the number of packages to build in parallel. Each is allowed to use all cores, but for this build, most do not use more than one. Therefore, it is recommended to set it to less than the number of physical cores in your machine.

Use Nix to build the filesystem image:

```
nixos-m1$ nix-build -A rootfs-bootstrap-cross -o rootfs -j4
```

The compressed image is now available in `rootfs/ext4-image/nixos_root.img.tar.gz`.

## Installation

#### U-Boot and Filesystem

Figure out the IP of the host Linux PC where you built everything (using e.g. `ip addr`). On that PC, change directories into the git repo and start an HTTP server for the Mac to download the files from:

```
nixos-m1$ nix-shell -p python3 --run 'python3 -m http.server'
```

Boot the Mac into 1TR and open the Terminal. Download the U-Boot image (replacing `.macho` with `.bin` if appropriate) and the compressed root filesystem from the host PC:

```
# curl http://<host PC IP>:8000/u-boot/u-boot.macho -o u-boot.macho
# curl http://<host PC IP>:8000/rootfs/ext4-image/nixos_root.img.tar.gz -o nixos_root.img.tar.gz
```

Use `kmutil` to install the `.macho` or `.bin` according to the [m1n1 manual](https://github.com/AsahiLinux/m1n1#usage), depending on your system.

```
# kmutil configure-boot <...>
```

In the Terminal, use the `diskutil list /dev/disk0` command to determine the blank partition on which to install the root filesystem (this is not the stub partition).

**DANGER: Damage to the first partition (`Apple_APFS_ISC`) or the last partition (`Apple_APFS_Recovery`) will render the Mac unbootable and unrecoverable without assistance from another computer!**

Having heeded the warning above, write the root filesystem to the appropriate partition, where `N` is its number, then shut down the machine:

```
# tar -xOf nixos_root.img.tar.gz | dd of=/dev/disk0sN bs=1m
# shutdown -h now
```

If on a laptop, connect your USB peripherals to a USB-C port through the USB A to C adapter. If on a Mac mini, you can use either the USB-A or USB-C ports. Connect the Ethernet cable to the network port or adapter as well.

Start the Mac, and U-Boot should start. After a short delay, NixOS will then start, and you will get a login prompt once booting completes.

#### NixOS Configuration

Create yourself a user account (here `foo`) with `sudo` privileges and give it a password:

```
nixos$ sudo useradd -G wheel -m foo
nixos$ sudo passwd foo
```

A working NixOS configuration file has been included in the root filesystem for you. Use `nano` to edit the file (other editors have been left out of the bootstrap filesystem to save space and time). Uncomment the relevant options and change their values as explained in the file. Refer to the [NixOS installation manual](https://nixos.org/manual/nixos/stable/index.html#ch-configuration) for further guidance (most documentation has also been left out of the bootstrap filesystem).

```
nixos$ sudo nano /etc/nixos/configuration.nix
```

Once you are satisfied with the configuration, rebuild the system to install it, then reboot the system. This will also have to download a large amount of data. If there are SSL errors, wait a minute or so for the time to be set correctly over the network.

```
nixos$ sudo nixos-rebuild boot
nixos$ sudo reboot
```

U-Boot will prompt you to select your new system (Generation 2) or the old system, which is the installer (Generation 1). If you wait a few seconds, it will automatically boot the latest generation. Your new system should now start and can be used like any other NixOS system. Refer to the manual for more information.

Note that Linux currently cannot completely shut down the system. Once you issue the command, you will have to hold the power button until the power shuts off completely. Rebooting should work fine though.

If something goes wrong, you can go back to the installer by selecting Generation 1 in the U-Boot menu (option 3 if you have only rebuilt the system once). There you can edit the configuration again and re-rebuild the system.

#### Hypervisor Boot

Once the root filesystem is installed, you can also choose to install m1n1 without U-Boot and run U-Boot and the OS under m1n1's hypervisor. To do this, instead download `m1n1/build/m1n1.macho` (or `.bin`) and install it using `kmutil`.

To run U-Boot under the hypervisor, start m1n1 and attach the Mac to the host PC using an appropriate USB cable, change directories to the repo, then run:

```
nixos-m1$ m1n1/bin/m1n1-run_guest u-boot/u-boot.macho
```

To access the serial console, in a separate terminal run:

```
$ nix-shell -p picocom --run 'picocom /dev/ttyACM1'
```

Downloading the kernel over USB is not supported at this time.

#### Cleanup

To recover the space on the host PC, change directories into the repo, remove the built symlinks (removing just the rootfs will recover almost all the space), then run the garbage collector:

```
nixos-m1$ rm m1n1 u-boot rootfs
nixos-m1$ nix-collect-garbage
```

To remove NixOS from the Mac, just delete the partition (taking care to not touch the recovery partitions) and reinstall m1n1 using `kmutil`.
