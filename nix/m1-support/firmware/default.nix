{ config, pkgs, lib, ... }:
{
  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation {
      name = "firmware";
      buildCommand = ''
        mkdir -p $out/lib/firmware
        FIRMWARE=`echo ${./.}/*firmware*.tar`
        if [ -e "$FIRMWARE" ]; then
          tar xf "$FIRMWARE" -C $out/lib/firmware
        else
          # stop nixos infra from breaking when it doesn't have any firmware
          touch $out/lib/firmware/.dummy
        fi
      '';
    })
  ];
}
