{ lib
, fetchFromGitLab
, mesa }:

(mesa.override {
  galliumDrivers = [ "swrast" "asahi" ];
  vulkanDrivers = [ "swrast" ];
  enableGalliumNine = false;
}).overrideAttrs (oldAttrs: {
  # version must be the same length (i.e. no unstable or date)
  # so that system.replaceRuntimeDependencies can work
  version = "23.1.0";
  src = fetchFromGitLab {
    # tracking: https://github.com/AsahiLinux/PKGBUILDs/blob/main/mesa-asahi-edge/PKGBUILD
    domain = "gitlab.freedesktop.org";
    owner = "asahi";
    repo = "mesa";
    rev = "asahi-20230311";
    hash = "sha256-Qy1OpjTohSDGwONK365QFH9P8npErswqf2TchUxR1tQ=";
  };
  # remove flag to configure xvmc functionality as having it
  # breaks the build because that no longer exists in Mesa 23
  mesonFlags = lib.filter (x: !(lib.hasPrefix "-Dxvmc-libs-path=" x)) oldAttrs.mesonFlags;
})
