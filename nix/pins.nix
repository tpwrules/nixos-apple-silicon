{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-12-05";
    url    = "https://github.com/NixOS/nixpkgs/archive/6e51c97f1c849efdfd4f3b78a4870e6aa2da4198.tar.gz";
    sha256 = "sha256:0d0alwdd07lsy4jl29wgn0m1z17ah9rwwggh7kpvg7a7skny24lc";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-10-25";
    url    = "https://github.com/oxalica/rust-overlay/archive/79b6e66bb76537c96707703f08630765e46148d1.tar.gz";
    sha256 = "sha256:0n5k3jdigp8bdwanwpnwyiapcvi9yn18dx2fg2vwrr937z8mlhii";
  };
}
