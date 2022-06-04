{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-05-31";
    url    = "https://github.com/NixOS/nixpkgs/archive/f1c167688a6f81f4a51ab542e5f476c8c595e457.tar.gz";
    sha256 = "sha256:00ac3axj7jdfcajj3macdydf9w9bvqqvgrqkh1xxr3rfi9q2fz1v";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
