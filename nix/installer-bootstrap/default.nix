{ pkgs, crossBuild ? false }:
(import (pkgs.path + "/nixos/lib/eval-config.nix") {
  specialArgs = { modulesPath = pkgs.path + "/nixos/modules"; };
  modules = [
    ./iso-configuration.nix
  ] ++ (if crossBuild then [ {
    nixpkgs.crossSystem = {
      system = "aarch64-linux";
    };
    boot.kernelBuildIsCross = true;
  } ] else [ ]);
}).config.system.build.isoImage
