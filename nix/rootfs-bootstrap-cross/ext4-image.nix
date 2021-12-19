# mod of https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/sd-card/sd-image.nix

{ config, lib, pkgs, ... }:

with lib;

let
  rootfsImage = pkgs.callPackage "${pkgs.path}/nixos/lib/make-ext4-fs.nix" ({
    inherit (config.sdImage) storePaths;
    compressImage = false;
    populateImageCommands = config.sdImage.populateRootCommands;
    volumeLabel = "NIXOS_SD";
  } // optionalAttrs (config.sdImage.rootPartitionUUID != null) {
    uuid = config.sdImage.rootPartitionUUID;
  });

  # we use tar and gzip to compress the image instead of the default zstd so
  # that it can be transferred and decompressed in recoveryOS (which doesn't
  # even have bare gzip, only tar!!!)
  compressedImage = if !config.sdImage.compressImage then rootfsImage else (
    pkgs.callPackage ({ pigz }: rootfsImage.overrideAttrs (o: {
      name = o.name + ".tar.gz";
      nativeBuildInputs = o.nativeBuildInputs ++ [ pigz ];
      buildCommand = ''
        imgout=$out
        out=nixos_root.img
      '' + o.buildCommand + ''
        out=$imgout
        echo "Compressing image"
        tar c nixos_root.img | pigz -p $NIX_BUILD_CORES -c > $out
      '';
    })
  )) {};
in
{
  config = {
    system.build.ext4Image = let
      ext4Name = replaceStrings ["sd"] ["ext4"] config.sdImage.imageName;
    in pkgs.callPackage ({ stdenv }: stdenv.mkDerivation {
      name = ext4Name;

      inherit (config.sdImage) compressImage;

      buildCommand = ''
        mkdir -p $out/nix-support $out/ext4-image
        export img=$out/ext4-image/nixos_root.img
        if test -n "$compressImage"; then
            export img=$img.tar.gz
        fi

        echo "${pkgs.stdenv.buildPlatform.system}" > $out/nix-support/system
        echo "file ext4-image $img" >> $out/nix-support/hydra-build-products

        ln -s ${compressedImage} $img
      '';
    }) {};
  };
}
