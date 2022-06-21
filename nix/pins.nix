{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-06-17";
    url    = "https://github.com/NixOS/nixpkgs/archive/3d7435c638baffaa826b85459df0fff47f12317d.tar.gz";
    sha256 = "sha256:19ahb9ww3r9p1ip9aj7f6rs53qyppbalz3997pzx2vv0aiaq3lz3";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
