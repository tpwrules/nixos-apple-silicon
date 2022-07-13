{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-07-11";
    url    = "https://github.com/NixOS/nixpkgs/archive/5f43d8b088d3771274bcfb69d3c7435b1121ac88.tar.gz";
    sha256 = "sha256:1fh5inlikm3090l0n14g8byiz7vzhna377pkvv2a7armwl1gs8ql";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
