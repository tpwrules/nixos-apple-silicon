{ config, pkgs, lib, ... }:

{
  imports = [
    # disable pulseaudio as the Asahi sound infrastructure can't use it.
    # if we disable it only if setupAsahiSound is enabled, then infinite
    # recursion results as pulseaudio enables config.sound by default.
    { config.hardware.pulseaudio.enable = false; }
  ];

  options.hardware.asahi = {
    setupAsahiSound = lib.mkOption {
      type = lib.types.bool;
      default = config.sound.enable;
      description = ''
        Set up the Asahi DSP components so that the speakers and headphone jack
        work properly and safely.
      '';
    };
  };

  config = let
    asahi-audio = pkgs.asahi-audio; # the asahi-audio we use

    lsp-plugins = pkgs.lsp-plugins; # the lsp-plugins we use

    lsp-plugins-is-patched = (lsp-plugins.overrideAttrs (old: {
      passthru = (old.passthru or {}) // {
        lsp-plugins-is-patched = builtins.elem "58c3f985f009c84347fa91236f164a9e47aafa93.patch"
          (builtins.map (p: p.name) (old.patches or []));
      };
    })).lsp-plugins-is-patched;

    lsp-plugins-is-safe = (pkgs.lib.versionAtLeast lsp-plugins.version "1.2.14") || lsp-plugins-is-patched;
  in lib.mkIf config.hardware.asahi.setupAsahiSound {
    # enable pipewire to run real-time and avoid audible glitches
    security.rtkit.enable = true;
    # set up pipewire with the supported capabilities (instead of pulseaudio)
    services.pipewire = {
      enable = true;

      alsa.enable = true;
      wireplumber.enable = true;
      pulse.enable = true;
    };

    # enable speakersafetyd to protect speakers
    systemd.packages = lib.mkAssert lsp-plugins-is-safe
      "lsp-plugins is unpatched/outdated and speakers cannot be safely enabled"
      [ pkgs.speakersafetyd ];
    services.udev.packages = [ pkgs.speakersafetyd ];

    # set up enivronment so that asahi-audio and UCM configs are used
    environment.etc = builtins.listToAttrs (builtins.map
      (f: { name = f; value = { source = "${asahi-audio}/share/${f}"; }; })
      asahi-audio.providedConfigFiles);
    environment.variables.ALSA_CONFIG_UCM2 = "${pkgs.alsa-ucm-conf-asahi}/share/alsa/ucm2";

    # set up pipewire and wireplumber to use asahi-audio configs and plugins
    systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;
    systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;
    systemd.user.services.pipewire.environment.LV2_PATH = let
      lv2Plugins = [ lsp-plugins pkgs.bankstown-lv2 ];
    in lib.makeSearchPath "lib/lv2" lv2Plugins;
    systemd.user.services.wireplumber.environment.LV2_PATH = let
      lv2Plugins = [ lsp-plugins pkgs.bankstown-lv2 ];
    in lib.makeSearchPath "lib/lv2" lv2Plugins;
  };
}
