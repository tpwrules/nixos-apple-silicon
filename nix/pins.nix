{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-10-25";
    url    = "https://github.com/NixOS/nixpkgs/archive/f994293d1eb8812f032e8919e10a594567cf6ef7.tar.gz";
    sha256 = "sha256:0j81pv6i6psq37250m0x1hjizykfdxmnh90561gkvyskb0klq2hv";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-10-25";
    url    = "https://github.com/oxalica/rust-overlay/archive/79b6e66bb76537c96707703f08630765e46148d1.tar.gz";
    sha256 = "sha256:0n5k3jdigp8bdwanwpnwyiapcvi9yn18dx2fg2vwrr937z8mlhii";
  };
}
