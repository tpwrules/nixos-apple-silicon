{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-07-21";
    url    = "https://github.com/NixOS/nixpkgs/archive/614a842b74b7a1497e8cfca7c61bec38f51911b3.tar.gz";
    sha256 = "sha256:0gkpnjdcrh5s4jx0i8dc6679qfkffmz4m719aarzki4jss4l5n5p";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
