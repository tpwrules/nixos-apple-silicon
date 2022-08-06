Attempts to get NixOS up on M1 Macs.

* [UEFI Boot Standalone NixOS (2022-08-05)](docs/uefi-standalone.md)

## Credits

This is mostly a restructuring of work many others have already done, and it wouldn't have been possible without them. Important parts of the Linux on M1 experience include:
* [Asahi Linux's m1n1 bootloader/hypervisor](https://github.com/AsahiLinux/m1n1)
* [Asahi Linux's kernel patches](https://github.com/AsahiLinux/linux)
* [Mark Kettenis' U-boot port](https://github.com/kettenis/u-boot)
* [Janne Grunau's kernel config](https://github.com/jannau/AsahiLinux-PKGBUILD/blob/main/linux-apple/config)

The Nix derivations and documentation in this repository are licensed under the MIT license as included in the [LICENSE](LICENSE) file. Patches included in this repository, and the files that Nix builds, are covered by separate licenses.
