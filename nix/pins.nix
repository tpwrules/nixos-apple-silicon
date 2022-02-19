{
  # https://hydra.nixos.org/jobset/mobile-nixos/unstable/evals
  # these evals have a cross-compiled stdenv available
  nixpkgs = fetchTarball {
    name   = "nixpkgs-unstable-2022-02-19";
    url    = "https://github.com/NixOS/nixpkgs/archive/23d785aa6f853e6cf3430119811c334025bbef55.tar.gz";
    sha256 = "sha256:00fvaap8ibhy63jjsvk61sbkspb8zj7chvg13vncn7scr4jlzd60";
  };
}
