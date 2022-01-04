# configuration that is specific to the ISO
{ config, pkgs, lib, ... }:
{
  imports = [
    ./installer-configuration.nix
    ../kernel
  ];

  # include those modules so the user can rebuild the install iso. that's not
  # especially useful at this point, but the user will need the kernel directory
  # for their own config. eventually we will have to figure out how to get the
  # ability to rebuild without connecting to the internet so the user can set
  # up wifi using the proprietary drivers
  installer.cloneConfigIncludes = [
    "./installer-configuration.nix"
    "./kernel"
  ];

  # copy the kernel and installer configs into the iso
  boot.postBootCommands = lib.optionalString config.installer.cloneConfig ''
    if ! [ -e /etc/nixos/kernel ]; then
      cp ${./installer-configuration.nix} /etc/nixos/installer-configuration.nix
      cp -r ${../kernel} /etc/nixos/kernel
    fi
  '';
}
