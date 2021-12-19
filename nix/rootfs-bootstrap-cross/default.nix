# mod of https://github.com/samueldr/cross-system/blob/master/default.nix

{ pkgs }:

let
  nixpkgsPath = pkgs.path;
  fromPkgs = path: pkgs.path + "/${path}";
  evalConfig = import (fromPkgs "nixos/lib/eval-config.nix");
in (evalConfig {
  specialArgs = {
    inherit nixpkgsPath;
  };
  modules = [
    ./configuration.nix
    ./ext4-image.nix
  ];
}).config.system.build.ext4Image
