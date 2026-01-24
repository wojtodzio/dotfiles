# Shared home-manager configuration
# Import this module to get common shell, programs, and packages
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./zsh.nix
    ./git.nix
    ./programs.nix
    ./packages.nix
    ./yazi.nix
    ./neovim.nix
    ./emacs.nix
    ./dotfiles.nix
  ];

  # Common home-manager settings
  programs.home-manager.enable = true;
}
