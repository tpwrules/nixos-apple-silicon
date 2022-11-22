{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-11-20";
    url    = "https://github.com/NixOS/nixpkgs/archive/af50806f7c6ab40df3e6b239099e8f8385f6c78b.tar.gz";
    sha256 = "sha256:19sgfjdzqkigajbns6jiyqr6yvacqjx5xqbz6p6aghzjfblb2nnn";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-10-25";
    url    = "https://github.com/oxalica/rust-overlay/archive/79b6e66bb76537c96707703f08630765e46148d1.tar.gz";
    sha256 = "sha256:0n5k3jdigp8bdwanwpnwyiapcvi9yn18dx2fg2vwrr937z8mlhii";
  };
}
