{ config, pkgs, lib, ... }:
{
  imports = [
    ./kernel
    ./mesa
    ./peripheral-firmware
    ./boot-m1n1
  ];

  config = {
    hardware.asahi.pkgs = if config.hardware.asahi.pkgsSystem != "aarch64-linux"
    then import (pkgs.path) {
        system = config.hardware.asahi.pkgsSystem;
        crossSystem.system = "aarch64-linux";
      }
    else pkgs;
  };

  options.hardware.asahi = {
    pkgsSystem = lib.mkOption {
      type = lib.types.str;
      default = "aarch64-linux";
      description = ''
        System architecture that should be used to build the major Asahi
        packages, if not the default aarch64-linux. This allows installing from
        a cross-built ISO without rebuilding them during installation.
      '';
    };

    pkgs = lib.mkOption {
      type = lib.types.raw;
      description = ''
        Package set used to build the major Asahi packages. Defaults to the
        ambient set if not cross-built, otherwise re-imports the ambient set
        with the system defined by `hardware.asahi.pkgsSystem`.
      '';
    };
  };
}
