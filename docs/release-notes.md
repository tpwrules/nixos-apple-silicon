# Release Notes

This file contains important information for each release.

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
