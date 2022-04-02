{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-03-25";
    url    = "https://github.com/NixOS/nixpkgs/archive/1d08ea2bd83abef174fb43cbfb8a856b8ef2ce26.tar.gz";
    sha256 = "sha256:1q8p2bz7i620ilnmnnyj9hgx71rd2j6sjza0s0w1wibzr9bx0z05";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-03-09";
    url    = "https://github.com/oxalica/rust-overlay/archive/7f599870402c8d2a5806086c8ee0f2d92b175c54.tar.gz";
    sha256 = "sha256:1dhwih79qndb19j58xnw4gx2340xxqkp0nrnjm674hl8h9fc5nnr";
  };
}
