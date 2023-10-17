{ config, pkgs, lib, ... }:

{
  options.hardware.asahi = {
    setupAlsaUcm = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
      '';
    };
  };

  config = lib.mkIf config.hardware.asahi.setupAlsaUcm {
    environment.variables = {
      ALSA_CONFIG_UCM2 = "${pkgs.alsa-ucm-conf-asahi}/share/alsa/ucm2";
    };
  };
}
