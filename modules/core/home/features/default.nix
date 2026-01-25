# Core Home Manager features (shared across all hosts)
_:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./programs.nix
    ./packages.nix
    ./dotfiles.nix
  ];
}
