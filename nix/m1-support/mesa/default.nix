{ config, pkgs, lib, ... }:
{
  config = let
    mesaAsahi = pkgs: pkgs.callPackage ./package.nix { mesa = pkgs.mesa; };
  in lib.mkIf config.hardware.asahi.useExperimentalGPUDriver {
    # Every package that references mesa should use the asahi mesa package.
    # This is for example required to make plasma wayland working, as otherwise
    # it would use the wrong mesa libraries.
    nixpkgs.config.packageOverrides = pkgs: {
      mesa = (mesaAsahi pkgs);
    };

    # As we override the mesa pkg in the "global" packages, we can reference mesa here directly
    hardware.opengl.package = pkgs.mesa.drivers;

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
