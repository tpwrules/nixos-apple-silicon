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

  mesonFlags =
    # remove flag to configure xvmc functionality as having it
    # breaks the build because that no longer exists in Mesa 23
    (lib.filter (x: !(lib.hasPrefix "-Dxvmc-libs-path=" x)) oldAttrs.mesonFlags) ++ [
      # we do not build any graphics drivers these features can be enabled for
      "-Dgallium-va=disabled"
      "-Dgallium-vdpau=disabled"
      "-Dgallium-xa=disabled"
      # does not make any sense
      "-Dandroid-libbacktrace=disabled"
      # do not want to add the dependencies
      "-Dlibunwind=disabled"
      "-Dlmsensors=disabled"
    ];

  # replace disk cache path patch with one tweaked slightly to apply to this version
  patches = lib.forEach oldAttrs.patches
    (p: if lib.hasSuffix "disk_cache-include-dri-driver-path-in-cache-key.patch" p
      then ./disk_cache-include-dri-driver-path-in-cache-key.patch else p);
})
