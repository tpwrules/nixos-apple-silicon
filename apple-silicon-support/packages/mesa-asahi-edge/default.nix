{ lib
, fetchFromGitLab
, mesa
}:

(mesa.override {
  galliumDrivers = [ "softpipe" "llvmpipe" "asahi" ];
  vulkanDrivers = [ "swrast" "asahi" ];
}).overrideAttrs (oldAttrs: {
  version = "25.0.0-asahi";
  src = fetchFromGitLab {
    # tracking: https://pagure.io/fedora-asahi/mesa/commits/asahi
    domain = "gitlab.freedesktop.org";
    owner = "asahi";
    repo = "mesa";
    rev = "asahi-20241211";
    hash = "sha256-Ny4M/tkraVLhUK5y6Wt7md1QBtqQqPDUv+aY4MpNA6Y=";
  };

  mesonFlags = let
    badFlags = [
      "-Dinstall-mesa-clc"
      "-Dopencl-spirv"
      "-Dgallium-nine"
    ];
    isBadFlagList = f: builtins.map (b: lib.hasPrefix b f) badFlags;
    isGoodFlag = f: !(builtins.foldl' (x: y: x || y) false (isBadFlagList f));
  in (builtins.filter isGoodFlag oldAttrs.mesonFlags) ++ [
      # we do not build any graphics drivers these features can be enabled for
      "-Dgallium-va=disabled"
      "-Dgallium-vdpau=disabled"
      "-Dgallium-xa=disabled"
    ];

  # replace patches with ones tweaked slightly to apply to this version
  patches = [
    ./opencl.patch
  ];

  postInstall = (oldAttrs.postInstall or "") + ''
    # we don't build anything to go in this output but it needs to exist
    touch $spirv2dxil
  '';
})
