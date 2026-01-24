# Dotfiles (pryrc, psqlrc, etc.)
{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.file = {
    ".pryrc".source = ../dotfiles/.pryrc;
    ".psqlrc".source = ../dotfiles/.psqlrc;
  };
}
