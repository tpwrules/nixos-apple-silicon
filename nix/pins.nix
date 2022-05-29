{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-05-28";
    url    = "https://github.com/NixOS/nixpkgs/archive/17b62c338f2a0862a58bb6951556beecd98ccda9.tar.gz";
    sha256 = "sha256:1yzbc85m9vbhsfprljzjkkskh9sxchid9m28wkgwsckqnf47r911";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
