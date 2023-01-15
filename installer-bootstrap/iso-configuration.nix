# configuration that is specific to the ISO
{ config, pkgs, lib, ... }:
{
  imports = [
    ./installer-configuration.nix
    ../nixos-module
  ];

  # include those modules so the user can rebuild the install iso. that's not
  # especially useful at this point, but the user will need the m1-support
  # directory for their own config.
  installer.cloneConfigIncludes = [
    "./installer-configuration.nix"
    "./m1-support/nixos-module"
  ];

  # copy the m1-support and installer configs into the iso
  boot.postBootCommands = lib.optionalString config.installer.cloneConfig ''
    if ! [ -e /etc/nixos/m1-support ]; then
      mkdir -p /etc/nixos/m1-support
      cp ${./installer-configuration.nix} /etc/nixos/installer-configuration.nix
      cp -r ${../packages} ${../nixos-module} -t /etc/nixos/m1-support
    fi
  '';
}
