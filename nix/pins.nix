{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-05-10";
    url    = "https://github.com/NixOS/nixpkgs/archive/2a3aac479caeba0a65b2ad755fe5f284f1fde74d.tar.gz";
    sha256 = "sha256:0px2fk64s56qxd8ir8xg8bsj5yz1w399ps4xfkyx29n2ywp9ar7c";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
