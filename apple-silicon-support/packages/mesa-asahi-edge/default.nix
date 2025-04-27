{ lib
, fetchFromGitLab
, mesa
}:

(mesa.override {
  galliumDrivers = [ "softpipe" "llvmpipe" "asahi" ];
  vulkanDrivers = [ "swrast" "asahi" ];
}).overrideAttrs (oldAttrs: {
  version = "25.1.0-asahi";
  src = fetchFromGitLab {
    # tracking: https://pagure.io/fedora-asahi/mesa/commits/asahi
    domain = "gitlab.freedesktop.org";
    owner = "asahi";
    repo = "mesa";
    rev = "asahi-20250221";
    hash = "sha256-xt49IaylZYoH3LxYu6Uxd+qRrqQfjI6FDeAD8MLeWP8=";
  };

  mesonFlags =
    let
      badFlags = [
        "-Dinstall-mesa-clc"
        "-Dopencl-spirv"
        "-Dgallium-nine"
      ];
      isBadFlagList = f: builtins.map (b: lib.hasPrefix b f) badFlags;
      isGoodFlag = f: !(builtins.foldl' (x: y: x || y) false (isBadFlagList f));
    in
    (builtins.filter isGoodFlag oldAttrs.mesonFlags) ++ [
      # we do not build any graphics drivers these features can be enabled for
      "-Dgallium-va=disabled"
      "-Dgallium-vdpau=disabled"
      "-Dgallium-xa=disabled"
    ];

  # replace patches with ones tweaked slightly to apply to this version
  patches = [
    ./opencl.patch
    ./system-gbm.patch
  ];

  postInstall = (oldAttrs.postInstall or "") + ''
    # we don't build anything to go in this output but it needs to exist
    touch $spirv2dxil
    touch $cross_tools
  '';
})
