# Neovim configuration shared between hosts
{
  config,
  lib,
  pkgs,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = ''
      " Use system clipboard
      set clipboard+=unnamedplus
    ''
    + lib.optionalString isDarwin ''
      " macOS-specific: Copy with CMD-c
      vnoremap <D-c> "+y
      nnoremap <D-c> V"+y

      " VSCode integration (macOS)
      vnoremap <D-i> <Cmd>call VSCodeNotify('interactiveEditor.start', 1)<CR>
      vnoremap <D-/> <Cmd>call VSCodeNotify('editor.action.commentLine', 1)<CR>
      vnoremap <=-=> <Cmd>call VSCodeNotify('editor.action.commentLine', 1)<CR>
    '';
  };
}
