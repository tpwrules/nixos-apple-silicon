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
    rev = "08ff98967079a2e43a04f11fc646eef51a9103f1";
    hash = "sha256-Y3AVHmajwJSD3cZejalF1SSt1R3RjMJf8SO3x1qTskw=";
  };
  mesonFlags = lib.filter (x: !(lib.hasPrefix "-Dxvmc-libs-path=" x)) oldAttrs.mesonFlags;
})
