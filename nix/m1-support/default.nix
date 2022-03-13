{ config, pkgs, lib, ... }:
{
  imports = [
    ./kernel
    ./firmware
    ./boot-m1n1
  ];
}
