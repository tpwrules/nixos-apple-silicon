{ config, pkgs, lib, ... }:
{
  config = let
    mesaAsahi = pkgs.callPackage ./package.nix { };
  in lib.mkIf config.hardware.asahi.useExperimentalGPUDriver {
    hardware.opengl.package = mesaAsahi.drivers;

    # required for GPU kernel driver
    hardware.asahi.addEdgeKernelConfig = true;
  };

  options.hardware.asahi.useExperimentalGPUDriver = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Use the experimental Asahi Mesa GPU driver.

      Do not report issues using this driver under NixOS to the Asahi project.
    '';
  };
}
