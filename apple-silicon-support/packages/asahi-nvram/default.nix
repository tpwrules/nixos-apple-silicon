{ fetchCrate
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "asahi-nvram";
  version = "0.2.1";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-bFUFjHVTYj0eUmhijraOdeCvAt2UGX8+yyvooYN1Uo0=";
  };

  cargoHash = "sha256-WhySIQew8xxdwXLWkpvTYQZFiqCEPjEAjr7NVxfjDkU=";
  cargoDepsName = pname;
}
