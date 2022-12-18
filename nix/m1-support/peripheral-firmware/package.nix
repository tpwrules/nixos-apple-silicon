{ pkgs
, peripheralFirmwareDirectory ? null # is this a smell?
,... }:
let
  asahi-fwextract = pkgs.callPackage ../asahi-fwextract {};
in pkgs.stdenv.mkDerivation {
  name = "asahi-peripheral-firmware";

  nativeBuildInputs = [ asahi-fwextract pkgs.cpio ];

  buildCommand = ''
    mkdir extracted
    asahi-fwextract ${/. + peripheralFirmwareDirectory} extracted

    mkdir -p $out/lib/firmware
    cat extracted/firmware.cpio | cpio -id --quiet --no-absolute-filenames
    mv vendorfw/* $out/lib/firmware
  '';
}

