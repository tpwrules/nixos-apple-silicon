{ config, pkgs, lib, ... }:

{
  options.hardware.asahi = {
    setupAlsaUcm = lib.mkOption {
      type = lib.types.bool;
      default = config.sound.enable;
      description = ''
	Enable the Asahi-specific ALSA UCM2 configs in the global environment
        so that headphone jack input and output work properly.
      '';
    };
  };

  config = lib.mkIf config.hardware.asahi.setupAlsaUcm {
    environment.variables = {
      ALSA_CONFIG_UCM2 = "${pkgs.alsa-ucm-conf-asahi}/share/alsa/ucm2";
    };
  };
}
