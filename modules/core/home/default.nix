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
    ./dotfiles.nix
    # Optional modules (moved to modules/optional/home/)
    ../../optional/home/yazi.nix
    ../../optional/home/neovim.nix
    ../../optional/home/emacs.nix
  ];

  # Common home-manager settings
  programs.home-manager.enable = true;
}
