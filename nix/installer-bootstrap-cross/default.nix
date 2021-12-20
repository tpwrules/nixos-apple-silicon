{ pkgs }:
(import (pkgs.path + "/nixos/lib/eval-config.nix") {
  specialArgs = { nixpkgsPath = pkgs.path; };
  modules = [ ./iso-cross-configuration.nix ];
}).config.system.build.isoImage
