{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-05-14";
    url    = "https://github.com/NixOS/nixpkgs/archive/d89d7af1ba23bd8a5341d00bdd862e8e9a808f56.tar.gz";
    sha256 = "sha256:09j336xnvwbq86v27xcbpmfjwjfzng7d0sdcrbpv60hc42dpdr8d";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
