{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-03-04";
    url    = "https://github.com/NixOS/nixpkgs/archive/3e072546ea98db00c2364b81491b893673267827.tar.gz";
    sha256 = "sha256:1b51j0zz4gfcmq1lzh0f9yj6h904p7fgskshvc70dkjkdg9k2x7j";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
