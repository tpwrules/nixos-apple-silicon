{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-03-12";
    url    = "https://github.com/NixOS/nixpkgs/archive/fcd48a5a0693f016a5c370460d0c2a8243b882dc.tar.gz";
    sha256 = "sha256:06nyvac1azpa9gqdhj9py6ljsvbfgx49ilp8kf6w0w9clxba64vg";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
