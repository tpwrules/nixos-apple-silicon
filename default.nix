let
  pins = import ./nix/pins.nix;
  overlays = [
    (import ./nix/overlay.nix)
    (import pins.rust-overlay)
  ];
in (import pins.nixpkgs { overlays = overlays; }).nixos-m1
