{ lib, buildGoModule, fetchFromGitHub, darwin }:

buildGoModule rec {
  pname = "pinentry-touchid";
  version = "v0.0.3";
  vendorHash = "sha256-PJJoTnA9WXzH9Yv/oZfwyjjcbvJwpXxX81vpzTtXWxU";

  src = fetchFromGitHub {
    owner = "jorgelbg";
    repo = "pinentry-touchid";
    rev = version;
    sha256 = "sha256-XMcJjVVAp5drLMVTShITl0v6uVazrG1/23dVerrsoj4";
  };

  buildInputs = with darwin.apple_sdk.frameworks; [ CoreFoundation Foundation LocalAuthentication ];

  subPackages = [ "." "go-assuan" "sensor" ];
  doCheck = false;

  NIX_CFLAGS_COMPILE = [
    # disable modules, otherwise we get redeclaration errors
    "-fno-modules"
  ];
}
