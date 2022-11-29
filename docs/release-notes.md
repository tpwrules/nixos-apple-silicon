# Release Notes

This file contains important information for each release.

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
