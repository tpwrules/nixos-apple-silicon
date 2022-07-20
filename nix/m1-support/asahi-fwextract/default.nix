{ lib
, python3
, fetchFromGitHub
, makeBinaryWrapper
}:

python3.pkgs.buildPythonApplication rec {
  pname = "asahi-fwextract";
  version = "0.4pre2";

  # tracking version: https://github.com/AsahiLinux/PKGBUILDs/blob/main/asahi-fwextract/PKGBUILD
  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "asahi-installer";
    rev = "v${version}";
    hash = "sha256-RqvD2hNjKMlUg+oY1woUN5zpN+1Y/TrBQbokNgdeCW4=";
  };

  patches = [
    ./add_entry_point.patch
  ];

  nativeBuildInputs = [ python3.pkgs.setuptools makeBinaryWrapper ];
}
