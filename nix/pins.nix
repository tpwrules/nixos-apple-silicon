{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-08-13";
    url    = "https://github.com/NixOS/nixpkgs/archive/c4a0efdd5a728e20791b8d8d2f26f90ac228ee8d.tar.gz";
    sha256 = "sha256:0rg066r8hx882hlhi4yvz6d8nyww7cqbjknyrsk0w44jj2jzaidg";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
