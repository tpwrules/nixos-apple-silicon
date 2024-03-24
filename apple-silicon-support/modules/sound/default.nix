{ config, options, pkgs, lib, ... }:

{
  imports = [
    # disable pulseaudio as the Asahi sound infrastructure can't use it.
    # if we disable it only if setupAsahiSound is enabled, then infinite
    # recursion results as pulseaudio enables config.sound by default.
    { config.hardware.pulseaudio.enable = (!config.hardware.asahi.enable); }
  ];

  options.hardware.asahi = {
    setupAsahiSound = lib.mkOption {
      type = lib.types.bool;
      default = config.sound.enable && config.hardware.asahi.enable;
      description = ''
        Set up the Asahi DSP components so that the speakers and headphone jack
        work properly and safely.
      '';
    };
  };

  config = let
    cfg = config.hardware.asahi;

    asahi-audio = pkgs.asahi-audio; # the asahi-audio we use

    lsp-plugins = pkgs.lsp-plugins; # the lsp-plugins we use

    lsp-plugins-is-patched = (lsp-plugins.overrideAttrs (old: {
      passthru = (old.passthru or {}) // {
        lsp-plugins-is-patched = builtins.elem "58c3f985f009c84347fa91236f164a9e47aafa93.patch"
          (builtins.map (p: p.name) (old.patches or []));
      };
    })).lsp-plugins-is-patched;

    lsp-plugins-is-safe = (pkgs.lib.versionAtLeast lsp-plugins.version "1.2.14") || lsp-plugins-is-patched;

    # https://github.com/NixOS/nixpkgs/pull/282377
    # options is the set of all module option declarations, rather than their
    # values, to prevent infinite recursion
    newHotness = builtins.hasAttr "configPackages" options.services.pipewire;

    lv2Path = lib.makeSearchPath "lib/lv2" [ lsp-plugins pkgs.bankstown-lv2 ];
  in lib.mkIf (cfg.setupAsahiSound && cfg.enable) (lib.mkMerge [
    {
      # enable pipewire to run real-time and avoid audible glitches
      security.rtkit.enable = true;
      # set up pipewire with the supported capabilities (instead of pulseaudio)
      # and asahi-audio configs and plugins
      services.pipewire = {
        enable = true;

        alsa.enable = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };

      # set up enivronment so that UCM configs are used as well
      environment.variables.ALSA_CONFIG_UCM2 = "${pkgs.alsa-ucm-conf-asahi}/share/alsa/ucm2";
      systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;
      systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;

      # enable speakersafetyd to protect speakers
      systemd.packages = lib.mkAssert lsp-plugins-is-safe
        "lsp-plugins is unpatched/outdated and speakers cannot be safely enabled"
        [ pkgs.speakersafetyd ];
      services.udev.packages = [ pkgs.speakersafetyd ];

      # downgrade wireplumber to a version compatible with the asahi-audio configs
      nixpkgs.overlays = [(final: prev: {
        wireplumber = prev.wireplumber.overrideAttrs (old:
          lib.optionalAttrs (lib.versionAtLeast old.version "0.5.0") rec {
            version = "0.4.17";
            src = final.fetchFromGitLab {
              domain = "gitlab.freedesktop.org";
              owner = "pipewire";
              repo = "wireplumber";
              rev = version;
              hash = "sha256-vhpQT67+849WV1SFthQdUeFnYe/okudTQJoL3y+wXwI=";
            };
          });
      })];
    }
    (lib.optionalAttrs newHotness {
      # use configPackages and friends to install asahi-audio and plugins
      services.pipewire = {
        configPackages = [ asahi-audio ];
        extraLv2Packages = [ lsp-plugins pkgs.bankstown-lv2 ];
        wireplumber = {
          configPackages = [ asahi-audio ];
          extraLv2Packages = [ lsp-plugins pkgs.bankstown-lv2 ];
        };
      };
    })
    (lib.optionalAttrs (!newHotness) {
      # use environment.etc and environment variables to install asahi-audio and plugins
      environment.etc = builtins.listToAttrs (builtins.map
        (f: { name = f; value = { source = "${asahi-audio}/share/${f}"; }; })
        asahi-audio.providedConfigFiles);

      systemd.user.services.pipewire.environment.LV2_PATH = lv2Path;
      systemd.user.services.wireplumber.environment.LV2_PATH = lv2Path;
    })
  ]);
}
