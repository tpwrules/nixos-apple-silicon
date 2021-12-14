# mod of https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/sd-card/sd-image.nix

{ config, lib, pkgs, ... }:

with lib;

let
  rootfsImage = pkgs.callPackage "${pkgs.path}/nixos/lib/make-ext4-fs.nix" ({
    inherit (config.sdImage) storePaths;
    compressImage = config.sdImage.compressImage;
    populateImageCommands = config.sdImage.populateRootCommands;
    volumeLabel = "NIXOS_SD";
  } // optionalAttrs (config.sdImage.rootPartitionUUID != null) {
    uuid = config.sdImage.rootPartitionUUID;
  });
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
        export img=$out/ext4-image/${ext4Name}
        if test -n "$compressImage"; then
            export img=$img.zst
        fi

        echo "${pkgs.stdenv.buildPlatform.system}" > $out/nix-support/system
        echo "file ext4-image $img" >> $out/nix-support/hydra-build-products

        ln -s ${rootfsImage} $img
      '';
    }) {};
  };
}
