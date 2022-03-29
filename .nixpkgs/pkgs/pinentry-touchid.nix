{ lib, buildGoModule, fetchFromGitHub, darwin }:

buildGoModule rec {
  pname = "pinentry-touchid";
  version = "1d7fbe6f06b48c6a0c253b894a6f770e2689aa14";
  vendorSha256 = "sha256-FN4F6ZWgSczmAMlEuigLGHivsXjvDJQVBZe6IrJTLrI=";

  src = fetchFromGitHub {
    owner = "jorgelbg";
    repo = "pinentry-touchid";
    rev = version;
    sha256 = "sha256-ccGROm9lgD6LO/pdXzd3XkHQh3qpEvRE/ZvxxPAnWm0=";
  };

  buildInputs = with darwin.apple_sdk.frameworks; [ CoreFoundation Foundation LocalAuthentication ];

  subPackages = [ "." "go-assuan" "sensor" ];
  doCheck = false;

  NIX_CFLAGS_COMPILE = [
    # disable modules, otherwise we get redeclaration errors
    "-fno-modules"
  ];
}
