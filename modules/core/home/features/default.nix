# Core Home Manager features (shared across all hosts)
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./programs.nix
    ./packages.nix
    ./dotfiles.nix
    # Import optional features
    ../../../optional/home/features
  ];
}
