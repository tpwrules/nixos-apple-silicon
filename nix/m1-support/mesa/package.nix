{ lib
, fetchFromGitLab
, mesa }:

(mesa.override {
  galliumDrivers = [ "swrast" "asahi" ];
  vulkanDrivers = [ "swrast" ];
  enableGalliumNine = false;
}).overrideAttrs (oldAttrs: {
  version = "23.0.0";
  # https://github.com/AsahiLinux/PKGBUILDs/blob/stable/mesa-asahi-edge/PKGBUILD
  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "asahi";
    repo = "mesa";
    rev = "01a8a3f3d6089d980e7ae56f6e631c8213f0e49d";
    hash = "sha256-i4W9pyoELTKFlhTMPIEHTmBGR21+kVDukm351XtPjL8=";
  };
  # remove flag to configure xvmc functionality as having it
  # breaks the build because that no longer exists in Mesa 23
  mesonFlags = lib.filter (x: !(lib.hasPrefix "-Dxvmc-libs-path=" x)) oldAttrs.mesonFlags;
})
