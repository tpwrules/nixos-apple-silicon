{ lib
, fetchFromGitHub
, alsa-ucm-conf }:

(alsa-ucm-conf.overrideAttrs (oldAttrs: rec {
  version = "4";

  src_asahi = fetchFromGitHub {
    # tracking: https://github.com/AsahiLinux/PKGBUILDs/blob/main/alsa-ucm-conf-asahi/PKGBUILD
    owner = "AsahiLinux";
    repo = "alsa-ucm-conf-asahi";
    rev = "v${version}";
    hash = "sha256-ZLPpFwWL47Vwc8tRvLo2m/3ocSVNSBHBIRLS+TENr78=";
  };
  
  postInstall = oldAttrs.postInstall or "" + ''
    cp -r ${src_asahi}/ucm2 $out/share/alsa
  '';
}))
