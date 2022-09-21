{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-09-18";
    url    = "https://github.com/NixOS/nixpkgs/archive/f677051b8dc0b5e2a9348941c99eea8c4b0ff28f.tar.gz";
    sha256 = "sha256:18zycb8zxnz20g683fgbvckckr7rmq7c1gf96c06fp8pmaak0akx";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
