{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-08-03";
    url    = "https://github.com/NixOS/nixpkgs/archive/168d1c578909dc143ba52dbed661c36e76b12b36.tar.gz";
    sha256 = "sha256:0iyasn0phr05dh4rwam2draprinh3db5dk83bg48v166v7bhq5qw";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
