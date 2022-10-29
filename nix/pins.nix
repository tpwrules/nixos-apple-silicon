{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-10-27";
    url    = "https://github.com/NixOS/nixpkgs/archive/2001e2b31c565bcdf7bc13062b8d7cfccaca05b8.tar.gz";
    sha256 = "sha256:00ckn1ng9cg78skzwi7rlzx7qragfwl1k7xi5qzfx9hmpsi7fpnx";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-10-25";
    url    = "https://github.com/oxalica/rust-overlay/archive/79b6e66bb76537c96707703f08630765e46148d1.tar.gz";
    sha256 = "sha256:0n5k3jdigp8bdwanwpnwyiapcvi9yn18dx2fg2vwrr937z8mlhii";
  };
}
