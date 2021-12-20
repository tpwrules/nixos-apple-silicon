# configuration that is specific to the cross-compiled ISO
{ config, pkgs, lib, ... }:
{
  imports = [
    ./installer-configuration.nix
    ../kernel
  ];

  nixpkgs.crossSystem = {
    system = "aarch64-linux";
  };
}
