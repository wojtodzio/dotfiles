# NixOS-specific home-manager configuration
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # NixOS-specific packages (if any)
  home.packages = with pkgs; [
    # Add NixOS-specific packages here
  ];

  home.stateVersion = "24.11";
}
