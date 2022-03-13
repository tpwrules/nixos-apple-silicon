{ config, pkgs, lib, ... }:
let
  buildPkgs = if config.boot.kernelBuildIsCross then
    import (pkgs.path) {
      system = "x86_64-linux";
      crossSystem.system = "aarch64-linux";
    }
  else pkgs;

  localPkgs = import (pkgs.path) { system = builtins.currentSystem; };

  boot = buildPkgs.callPackage ../u-boot {
    m1n1 = buildPkgs.callPackage ../m1n1 {
      isRelease = true;
      withTools = false;
      # even though this is a nativeBuildInput, using a cross system
      # triggers a rebuild for reasons I don't quite understand
      imagemagick = if config.boot.kernelBuildIsCross
        then (import (pkgs.path) { system = "x86_64-linux"; }).imagemagick
        else localPkgs.imagemagick;
    };
  };

  bootFiles = {
    "m1n1/boot.bin" = "${boot}/m1n1-u-boot.bin";
  };
in {
  # install m1n1 with the boot loader
  boot.loader.grub.extraFiles = bootFiles;
  boot.loader.systemd-boot.extraFiles = bootFiles;

  # ensure the installer has m1n1 in the image
  system.extraDependencies = lib.mkForce [ boot ];
}
