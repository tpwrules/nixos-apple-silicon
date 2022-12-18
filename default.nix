let
  pins = import ./nix/pins.nix;
  overlays = [
    (import ./nix/overlay.nix)
    (import ./nix/m1-support/overlay.nix) # our packages ambient
    (import pins.rust-overlay)
  ];
in {
  nixpkgs ? pins.nixpkgs
}: (import nixpkgs { overlays = overlays; }).nixos-m1
