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

  # Common session variables
  home.sessionVariables = {
    # Usage in scripts: eval $DEBUGGER
    # Note: Uses \$ to prevent evaluation at shell init (only eval when DEBUGGER is used)
    DEBUGGER = ''
      while IFS="\n" read -erp "[\$(basename \''${BASH_SOURCE[0]:-script}):\$LINENO]> " command_to_execute; do
                             eval "\$command_to_execute";
                           done;
                           echo'';
  };
}
