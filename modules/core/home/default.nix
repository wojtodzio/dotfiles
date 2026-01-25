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
    ./features
  ];

  # Common home-manager settings
  programs.home-manager.enable = true;
}
