{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-03-16";
    url    = "https://github.com/NixOS/nixpkgs/archive/73ad5f9e147c0d2a2061f1d4bd91e05078dc0b58.tar.gz";
    sha256 = "sha256:01j7nhxbb2kjw38yk4hkjkkbmz50g3br7fgvad6b1cjpdvfsllds";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
