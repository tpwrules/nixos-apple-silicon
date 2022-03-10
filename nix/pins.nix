{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-02-23";
    url    = "https://github.com/NixOS/nixpkgs/archive/7f9b6e2babf232412682c09e57ed666d8f84ac2d.tar.gz";
    sha256 = "sha256:03nb8sbzgc3c0qdr1jbsn852zi3qp74z4qcy7vrabvvly8rbixp2";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
