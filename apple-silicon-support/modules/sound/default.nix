{ config, pkgs, lib, ... }:

{
  options.hardware.asahi = {
    setupAsahiSound = lib.mkOption {
      type = lib.types.bool;
      default = config.sound.enable;
      description = ''
        Set up the Asahi DSP components
      '';
    };
  };

  config = lib.mkIf config.hardware.asahi.setupAsahiSound {

    systemd.packages = [ pkgs.speakersafetyd ];
    services.udev.packages = [ pkgs.speakersafetyd ];

    environment.etc.asahi-audio = {
      source = "${pkgs.asahi-audio}/share";
      target = "";
    };

    environment.variables.ALSA_CONFIG_UCM2 = "${pkgs.alsa-ucm-conf-asahi}/share/alsa/ucm2";
    systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;
    systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;
    systemd.user.services.pipewire.environment.LV2_PATH = let
      lv2Plugins = [ pkgs.lsp-plugins pkgs.bankstown-lv2 ];
    in lib.makeSearchPath "lib/lv2" lv2Plugins;
    systemd.user.services.wireplumber.environment.LV2_PATH = let
      lv2Plugins = [ pkgs.lsp-plugins pkgs.bankstown-lv2 ];
    in lib.makeSearchPath "lib/lv2" lv2Plugins;
  };
}
