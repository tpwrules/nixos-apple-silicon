{ fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "asahi-battery-threshold";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "PaddiM8";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-kYW/8fM4k0gY39huaWEeSeAuq+Qz+7LXd0ujnkRf8zY=";
  };

  cargoHash = "sha256-ZiIYJfespxgYZO1SDUuf0Gpiz+X3R+F0B93HbeHc4Z8=";

  meta.mainProgram = "asahi-battery-threshold";
}

