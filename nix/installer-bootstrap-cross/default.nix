{ pkgs }:
(import (pkgs.path + "/nixos/lib/eval-config.nix") {
  specialArgs = { modulesPath = pkgs.path + "/nixos/modules"; };
  modules = [ ./iso-cross-configuration.nix ];
}).config.system.build.isoImage
