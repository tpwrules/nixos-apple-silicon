{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2023-01-13";
    url    = "https://github.com/NixOS/nixpkgs/archive/befc83905c965adfd33e5cae49acb0351f6e0404.tar.gz";
    sha256 = "sha256:0m0ik7z06q3rshhhrg2p0vsrkf2jnqcq5gq1q6wb9g291rhyk6h2";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-10-25";
    url    = "https://github.com/oxalica/rust-overlay/archive/79b6e66bb76537c96707703f08630765e46148d1.tar.gz";
    sha256 = "sha256:0n5k3jdigp8bdwanwpnwyiapcvi9yn18dx2fg2vwrr937z8mlhii";
  };
}
