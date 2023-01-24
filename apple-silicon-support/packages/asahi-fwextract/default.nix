{ lib
, python3
, fetchFromGitHub
, gzip
, gnutar
, lzfse
}:

python3.pkgs.buildPythonApplication rec {
  pname = "asahi-fwextract";
  version = "0.5pre2";

  # tracking version: https://github.com/AsahiLinux/PKGBUILDs/blob/main/asahi-fwextract/PKGBUILD
  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "asahi-installer";
    rev = "v${version}";
    hash = "sha256-p34eN2iE1s8rupdysjyf6GN8kHkVG9NDw31YKPDNXbk=";
  };

  patches = [
    ./add_entry_point.patch
  ];

  postPatch = ''
    substituteInPlace asahi_firmware/img4.py \
      --replace 'liblzfse.so' '${lzfse}/lib/liblzfse.so'
    substituteInPlace asahi_firmware/update.py \
      --replace '"tar"' '"${gnutar}/bin/tar"' \
      --replace '"xf"' '"-x", "-I", "${gzip}/bin/gzip", "-f"'
  '';

  nativeBuildInputs = [ python3.pkgs.setuptools ];

  doCheck = false;
}
