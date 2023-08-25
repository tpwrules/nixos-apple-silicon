# Release Notes

This file contains important information for each release.

## 2023-08-25

This release updates nixpkgs, m1n1, the kernel, and Mesa.

Thanks to yu-re-ka, Lucus16, and Enzime for help with these updates.

## 2023-08-19

This release updates nixpkgs and Mesa.

In particular, nixpkgs is updated to fix a regression in cross-compilation
and a non-deterministic build failure of GRUB.

## 2023-08-08

This release does not update any software.

This release includes a patch to allow building with Rust 1.71.0 in the
latest nixpkgs releases. Nixpkgs itself is not yet updated due to a
regression in cross-compilation.

## 2023-07-26

This release updates nixpkgs, the Asahi kernel, and Mesa.

## 2023-07-12

This release does not update any software.

This release corrects an issue where the kernel would not build with Rust
support when using the latest stable nixpkgs release due to a patch that was
applied when it should not have been. Thanks to natsukagami for noticing and
correcting the issue.

Support for stable nixpkgs releases is neither tested nor guaranteed, but
patches to address specific issues are welcome.

## 2023-07-11

This release updates nixpkgs, the Asahi kernel, and Mesa.

This release adds the ability to build the installer and packages when not using
flakes through the inclusion of flake-compat. Thanks to flokli for this
contribution.

## 2023-06-25

This release updates nixpkgs. There have been no changes to Asahi's stable
package versions since the last release.

This release corrects problems building the Linux kernel Rust graphics driver
using recent nixpkgs releases. Thanks to yu-re-ka and the Asahi team for
patches.

This release also finally eliminates IFD when building the kernel.

## 2023-06-15

This release updates nixpkgs, the Asahi kernel, and Mesa.

Updating nixpkgs fixes an issue uncovered by the last release which would cause
`nixos-generate-config` to generate a hardware configuration which would build
for the wrong system type.

Updating the Asahi packages fixes some graphics issues using the experimental
GPU driver.

## 2023-06-07

This release updates nixpkgs and all Asahi package versions, including the
kernel, m1n1, U-Boot, and Mesa.

Updating nixpkgs brings us past the 23.05 release and on the path to 23.11.

Updating m1n1 fixes some issues with virtualization.

Updating U-Boot fixes issues with certain USB devices causing U-Boot to crash
and allows use of all USB ports on all Macs (IIUC).

Due to a quirk in the new version of U-Boot, a revised command is required to
boot off a flash drive when a system is already installed on the internal disk.
This command is as follows: `env set boot_efi_bootmgr ; run bootcmd_usb0`.
Hopefully this quirk will be addressed in a future release.

## 2023-05-06

This release updates nixpkgs. There have been no changes to Asahi's stable
package versions since the last release.

This release corrects problems building the Linux kernel Rust graphics driver
using recent nixpkgs releases. Thanks to yu-re-ka and QuentinI for patches.

This release also reduces the amount of IFD involved in building the kernel.
Thanks again to QuentinI for this contribution.

## 2023-03-21

This release updates nixpkgs and the Asahi packages, including the kernel, m1n1,
U-Boot, and Mesa.

Updating nixpkgs finally brings GCC 12 as the default compiler.

## 2023-02-23

This release updates nixpkgs. There have been no changes to Asahi's stable
package versions since the last release.

This release corrects build failures of the Linux kernel using either the latest
NixOS unstable or NixOS 22.11 versions of the Rust compiler.

## 2023-01-31

**This release reorganizes the project substantially. Please follow the
directions below or the upgrade might not take effect.**

This release updates nixpkgs and reorganizes the project. There have been no
changes to Asahi's stable package versions since the last release.

To upgrade (assuming you used the standard installation instructions):
* Remove `/etc/nixos/m1-support`
* Procure the `apple-silicon-support` directory from the repo and place it in
  `/etc/nixos/apple-silicon-support`
* Change the `./m1-support` include path in your configuration.nix to
  `./apple-silicon-support`.

Thanks primarily to the hard work of oati, the project has been reorganized to
cleanly separate the Nixpkgs package definitions and overlay, the NixOS
modules, and the custom bootstrap installer configuration. This will make
development and customization more straightforward. The project has also been
renamed to emphasize compatibility with all generations of Apple Silicon Macs
(though be mindful that support of a particular machine by this project cannot
come until Asahi Linux does the hard parts!).

Flakes support is now required to build the installer. The installer ISO and
development versions of m1n1 and U-Boot are now available as outputs of this
repository's flake. The overlay and NixOS modules are also available as outputs
for the convenience of system flakes users.

## 2023-01-18

This release updates nixpkgs. There have been no changes to Asahi's
stable package versions since the last release.

This release corrects build failures when the kernel is built with Rust support.
These were a result of Nixpkgs' upgrade to Rust 1.66.

This release also adds an option `hardware.asahi.experimentalGPUInstallMode` to
select the way in which the experimental GPU driver is installed.
There are three choices:
* `driver`: install only as a driver, do not replace system Mesa. Causes issues
  with certain programs like Plasma Wayland.
* `replace` (the default): use `system.replaceRuntimeDependencies` to replace
  system Mesa with Asahi Mesa. Does not work in pure evaluation context (i.e. in
  flakes by default).
* `overlay`: overlay system Mesa with Asahi Mesa. Requires rebuilding the
  world.

## 2023-01-16

This release updates nixpkgs. There have been no changes to Asahi's
stable package versions since the last release.

This release also solves an issue where Plasma Wayland sessions would
not launch when using experimental GPU support due to mismatched Mesa
versions. (Thanks bkchr!)

## 2022-12-26

This release updates upstream dependencies, including nixpkgs and Mesa.

Updating nixpkgs in particular resolves an issue which broke reproducibility of
the installer ISO when building on some filesystems, like ZFS.

The curl, wget, and
[wormhole-william](https://github.com/psanford/wormhole-william) utilities are
now included in the installer image to ease file transfer and initial setup.
wormhole-william is interoperable with the
[Magic Wormhole](https://magic-wormhole.readthedocs.io/en/latest/) utility.
(Thanks zzywysm!)

U-Boot is now built with a double-size font so that its console can be
practically read on Retina displays. (Thanks again zzywysm!)

## 2022-12-18

This release updates upstream dependencies including nixpkgs, the kernel,
and m1n1.

Updating nixpkgs resolves an issue that might have caused NetworkManager's GUI
to crash after entering a Wi-Fi password.

Support for Rust in the kernel, the Asahi edge kernel config, and the
experimental Mesa driver are now included as NixOS options.

* Enable the option `hardware.asahi.withRust` to build the kernel with the
Rust toolchain present. GCC is still used for the kernel's C code.
* Enable the option `hardware.asahi.addEdgeKernelConfig` to add the official
Asahi edge kernel configuration options. This implies the previous option.
* Enable the option `hardware.asahi.useExperimentalGPUDriver` to switch the
system version of Mesa to the Asahi project's fork which includes experimental
support for the Apple Silicon GPU. This implies the previous two options.

Please note that, as outlined in the
[official blog post](https://asahilinux.org/2022/12/gpu-drivers-now-in-asahi-linux/),
there are likely to be issues with many applications using the experimental
GPU drivers. **Do not report any GPU driver issues encountered under NixOS to
the Asahi project. Replicate your issue and gather relevant information as
described in the post using the official distro instead!**

The GPU drivers have been tested and verified functional under NixOS on an
M1 Max MacBook Pro 16" with X11, Xfce, SuperTuxKart, and WebGL under Firefox.

## 2022-12-06

This release updates upstream dependencies including nixpkgs, the kernel,
and m1n1. Nixpkgs is now officially 23.05pre.

The `boot.kernelPackages` NixOS option is now respected properly by the
manual kernel builder. (Thanks natsukagami!)

## 2022-11-29

This release corrects an issue which would cause booting off a USB flash
drive from a boot environment with the latest device trees to fail with
the message "An error occurred in stage 1 of the boot process."

The cause was new functionality in new kernel modules which was required
for the USB ports to work. These modules were made available in the
initrd so the system can mount the USB flash drive and continue booting.

The fix has been verified on a MacBook Pro M1 Max 16".

## 2022-11-24

This release updates to the latest Asahi kernel and other stuff. Currently only
the non-edge config is supported.

Sound is not yet fully supported. Work remains to integrate the ALSA UCM
configurations into NixOS. This will be addressed in the future.

The 4K patch no longer applies so this kernel only operates in 16K mode for now.
This is not planned to be addressed. PRs are welcome for an updated patch.

Due to a change in the device trees, booting old kernels with the latest trees,
i.e. switching to an older generation using the bootloader, may leave you with
broken USB support. Once booted into the generation, you can run
`/run/current-system/bin/switch-to-configuration switch` then reboot to force
the bootloader and the correct version of U-Boot/m1n1/the device trees to be
reinstalled and loaded.

The edge config and a prototype of the GPU driver will be addressed in the
future.
