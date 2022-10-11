{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-10-08";
    url    = "https://github.com/NixOS/nixpkgs/archive/c5924154f000e6306030300592f4282949b2db6c.tar.gz";
    sha256 = "sha256:0idnlkn01d43hsb9rgnvngvvaphzirhifzq5hx57drpg28f63l9q";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
