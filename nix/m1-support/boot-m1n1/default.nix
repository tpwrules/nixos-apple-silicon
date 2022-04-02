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
    "m1n1/boot.bin" = if config.boot.m1n1ExtraOptions == "" then
      "${boot}/m1n1-u-boot.bin"
    else pkgs.runCommand "boot.bin" {} ''
      cat ${boot}/m1n1-u-boot.bin > $out
      echo '${config.boot.m1n1ExtraOptions}' >> $out
    '';
  };
in {
  config = {
    # install m1n1 with the boot loader
    boot.loader.grub.extraFiles = bootFiles;
    boot.loader.systemd-boot.extraFiles = bootFiles;

    # ensure the installer has m1n1 in the image
    system.extraDependencies = lib.mkForce [ boot ];
  };

  options.boot.m1n1ExtraOptions = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = ''
      Append extra options to the m1n1 boot binary. Might be useful for fixing
      display problems on Mac minis.
      https://github.com/AsahiLinux/m1n1/issues/159
    '';
  };
}
