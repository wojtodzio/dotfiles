# Optional Home Manager features (editors, file managers)
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./emacs.nix
    ./neovim.nix
    ./yazi.nix
  ];
}
