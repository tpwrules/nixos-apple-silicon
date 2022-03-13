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
        fi
      '';
    })
  ];
}
