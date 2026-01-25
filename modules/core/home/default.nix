# Shared home-manager configuration
# Import this module to get common shell, programs, and packages
_:

{
  imports = [
    ./features
  ];

  # Common home-manager settings
  programs.home-manager.enable = true;
}
