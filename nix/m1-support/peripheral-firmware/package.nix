{ pkgs
, peripheralFirmwareDirectory ? null # is this a smell?
,... }:
pkgs.stdenv.mkDerivation {
  name = "asahi-peripheral-firmware";

  nativeBuildInputs = with pkgs; [ asahi-fwextract cpio ];

  buildCommand = ''
    mkdir extracted
    asahi-fwextract ${/. + peripheralFirmwareDirectory} extracted

    mkdir -p $out/lib/firmware
    cat extracted/firmware.cpio | cpio -id --quiet --no-absolute-filenames
    mv vendorfw/* $out/lib/firmware
  '';
}

