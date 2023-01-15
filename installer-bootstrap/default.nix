{ pkgs, crossBuild ? false }:
(import (pkgs.path + "/nixos/lib/eval-config.nix") {
  inherit (pkgs) system;
  specialArgs = { modulesPath = pkgs.path + "/nixos/modules"; };
  modules = [
    ./iso-configuration.nix
  ] ++ (
    pkgs.lib.optional crossBuild {
      nixpkgs.crossSystem.system = "aarch64-linux";
      hardware.asahi.pkgsSystem = pkgs.stdenv.system;
    }
  );
}).config
