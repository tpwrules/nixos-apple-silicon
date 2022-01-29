{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  # note that we can't upgrade past 2021-12-24 now because of libunwind
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2021-12-24";
    url    = "https://github.com/NixOS/nixpkgs/archive/cb372c3b8880e504b06946e8fb2ca9777c685505.tar.gz";
    sha256 = "sha256:0m5k2vkhdd3049pcrampw4xb7hvf9f44pp18y765fvdwwvgqasw7";
  };
}
