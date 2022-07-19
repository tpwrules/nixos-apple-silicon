{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-07-18";
    url    = "https://github.com/NixOS/nixpkgs/archive/8f485713f5e6b6883a9b6959afa98688360a3ecb.tar.gz";
    sha256 = "sha256:0gvp331v64azn7v29p3qgbjq2i0sp8bwbnsbrk0yffyjzpfvdvwq";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
