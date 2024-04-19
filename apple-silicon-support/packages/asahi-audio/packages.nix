{ lib, callPackage, fetchFromGitHub }:

let
  # tracking: https://src.fedoraproject.org/rpms/asahi-audio
  # note: ensure that the providedConfigFiles list below is current!
  owner = "AsahiLinux";
  repo = "asahi-audio";

  callPackage' = args: callPackage (import ./common.nix {
    inherit (args) version providedConfigFiles;

    src = fetchFromGitHub rec {
      inherit owner repo;
      inherit (args) rev hash;
    };
  }) { };
in {
  asahi-audio-1_x = callPackage' rec {
    version = "1.8";
    rev = "v${version}";
    hash = "sha256-+3nmBJbyxw+8PZ3di1YVImU6tNPK4q5xC70WQK7jnOk=";

    providedConfigFiles = [
      "wireplumber/wireplumber.conf.d/99-asahi.conf"
      "wireplumber/policy.lua.d/85-asahi-policy.lua"
      "wireplumber/main.lua.d/85-asahi.lua"
      "wireplumber/scripts/policy-asahi.lua"
      "pipewire/pipewire.conf.d/99-asahi.conf"
      "pipewire/pipewire-pulse.conf.d/99-asahi.conf"
    ];
  };

  asahi-audio-2_x = callPackage' {
    version = "2.0+git20240418";
    rev = "29ec1056c18193ffa09a990b1b61ed273e97fee6";
    hash = "sha256-OwzO1x3rUajB/XMUnBGhTKKD9D36izFmCRd7JALumHc=";

    providedConfigFiles = [
      "wireplumber/wireplumber.conf.d/99-asahi.conf"
      "wireplumber/scripts/device/asahi-limit-volume.lua"
      "pipewire/pipewire.conf.d/99-asahi.conf"
      "pipewire/pipewire-pulse.conf.d/99-asahi.conf"
    ];
  };
}
