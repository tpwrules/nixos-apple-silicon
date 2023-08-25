# the Asahi Linux edge config and options that must go along with it

{ config, pkgs, lib, ... }:
{
  config = lib.mkIf config.hardware.asahi.addEdgeKernelConfig {
    boot.kernelPatches = [
      {
        name = "edge-config";
        patch = null;
        # derived from
        # https://github.com/AsahiLinux/PKGBUILDs/blob/main/linux-asahi/config.edge
        extraConfig = ''
          DRM_APPLE m
          DRM_VGEM n
          DRM_SCHED y
          DRM_GEM_SHMEM_HELPER y
          DRM_ASAHI m
          SUSPEND y
        '';
      }
    ];

    # required for proper DRM setup even without GPU driver
    services.xserver.config = ''
      Section "OutputClass"
          Identifier "appledrm"
          MatchDriver "apple"
          Driver "modesetting"
          Option "PrimaryGPU" "true"
      EndSection
    '';

    # required for edge drivers
    hardware.asahi.withRust = true;
  };

  options.hardware.asahi.addEdgeKernelConfig = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Build the Asahi Linux kernel with additional experimental "edge"
      configuration options.
    '';
  };
}
