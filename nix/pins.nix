{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2023-01-15";
    url    = "https://github.com/NixOS/nixpkgs/archive/6dccdc458512abce8d19f74195bb20fdb067df50.tar.gz";
    sha256 = "sha256:1is1icy39vvij73zv74qxc644agrgwpfvn5375k974ifx7s64inn";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-10-25";
    url    = "https://github.com/oxalica/rust-overlay/archive/79b6e66bb76537c96707703f08630765e46148d1.tar.gz";
    sha256 = "sha256:0n5k3jdigp8bdwanwpnwyiapcvi9yn18dx2fg2vwrr937z8mlhii";
  };
}
