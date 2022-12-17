{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-12-15";
    url    = "https://github.com/NixOS/nixpkgs/archive/0f5996b524c91677891a432cc99c7567c7c402b1.tar.gz";
    sha256 = "sha256:00hbygrmx6pbh59s9c5hsi1jgl4frzcxlyjy0g6l4s58l8phw27a";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-10-25";
    url    = "https://github.com/oxalica/rust-overlay/archive/79b6e66bb76537c96707703f08630765e46148d1.tar.gz";
    sha256 = "sha256:0n5k3jdigp8bdwanwpnwyiapcvi9yn18dx2fg2vwrr937z8mlhii";
  };
}
