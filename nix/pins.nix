{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-03-07";
    url    = "https://github.com/NixOS/nixpkgs/archive/062a0c5437b68f950b081bbfc8a699d57a4ee026.tar.gz";
    sha256 = "sha256:0vfd7g1gwy9lcnnv8kclqr68pndd9sg0xq69h465zbbzb2vnijh9";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
