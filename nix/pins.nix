{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-12-22";
    url    = "https://github.com/NixOS/nixpkgs/archive/f2a15bc22fa14a91b6f6a2e01bf4ff4db72528e3.tar.gz";
    sha256 = "sha256:104x6h43k66nfi75g8ss792cr1ddqqc5zf95m9ycpj8hqba64jg5";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-10-25";
    url    = "https://github.com/oxalica/rust-overlay/archive/79b6e66bb76537c96707703f08630765e46148d1.tar.gz";
    sha256 = "sha256:0n5k3jdigp8bdwanwpnwyiapcvi9yn18dx2fg2vwrr937z8mlhii";
  };
}
