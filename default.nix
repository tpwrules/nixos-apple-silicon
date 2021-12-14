let
  pins = import ./nix/pins.nix;
  overlays = [
    (import ./nix/overlay.nix)
  ];
in (import pins.nixpkgs { overlays = overlays; }).nixos-m1
