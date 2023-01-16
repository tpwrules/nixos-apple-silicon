{ pkgs }:
(import (pkgs.path + "/nixos/lib/eval-config.nix") {
  specialArgs = { modulesPath = pkgs.path + "/nixos/modules"; };
  modules = [
    ./iso-configuration.nix
    {
      nixpkgs.crossSystem.system = "aarch64-linux";
      nixpkgs.localSystem.system = pkgs.system;
      hardware.asahi.pkgsSystem = pkgs.system;
    }
  ];
}).config
