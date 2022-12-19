{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-12-16";
    url    = "https://github.com/NixOS/nixpkgs/archive/08b5fc6d8c4fda44b5b98e36c294c5e031f3ef1c.tar.gz";
    sha256 = "sha256:1xzj1l5fz8az7a8k5dkdhljikiq00kl67rdqy0jnpj5hr81yd58n";
  };

  rust-overlay = fetchTarball {
    name   = "rust-overlay-2022-10-25";
    url    = "https://github.com/oxalica/rust-overlay/archive/79b6e66bb76537c96707703f08630765e46148d1.tar.gz";
    sha256 = "sha256:0n5k3jdigp8bdwanwpnwyiapcvi9yn18dx2fg2vwrr937z8mlhii";
  };
}
