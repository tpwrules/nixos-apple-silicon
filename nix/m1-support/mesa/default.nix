{ config, pkgs, lib, ... }:
{
  config = let
    mesaAsahi = pkgs.callPackage ./package.nix { };
  in lib.mkIf config.hardware.asahi.useExperimentalGPUDriver {
    # some programs (like Plasma Wayland) are broken if the version of
    # Mesa they link against is different to the one driving the
    # graphics card. replace the Mesa linked into system packages with
    # the Asahi one without rebuilding the world. it's unclear if the
    # issue is simply slightly different Mesa versions or the
    # modifications required for the Apple GPU but the replacement is
    # safe enough and this is all experimental anyway.
    system.replaceRuntimeDependencies = [
      { original = pkgs.mesa;
        replacement = mesaAsahi;
      }
    ];

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
