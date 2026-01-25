# Dotfiles (pryrc, psqlrc, etc.)
{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.file = {
    ".pryrc".source = ../../../shared/dotfiles/.pryrc;
    ".psqlrc".source = ../../../shared/dotfiles/.psqlrc;
  };
}
