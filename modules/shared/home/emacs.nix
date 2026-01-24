# Emacs configuration shared between hosts
{
  config,
  lib,
  pkgs,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;
  unstable = pkgs.unstable;
in
{
  programs.emacs = {
    enable = true;
    package = unstable.emacs30;
    extraPackages = epkgs: [
      epkgs.vterm
    ];
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.emacs.d/bin"
  ];

  home.packages =
    with pkgs;
    [
      # Core emacs dependencies
      (ripgrep.override { withPCRE2 = true; })
      fd
      zstd
      jq
      editorconfig-core-c
      fontconfig

      # LSP
      nil # Nix LSP

      # vterm dependencies
      cmake

      # Org mode
      graphviz

      # Docker
      dockfmt

      # Web
      stylelint
      jsbeautifier

      # Shell
      shfmt
      shellcheck

      # Rust
      rustc
      rust-analyzer
      cargo

      # Go
      gopls
      gomodifytags
      gotests
      gore
      gotools

      # Markdown
      pandoc

      # Ruby
      pry
      bundix

      # LSP booster
      emacs-lsp-booster
    ]
    ++ lib.optionals isDarwin [
      # macOS-specific emacs packages
      coreutils-prefixed
      glibtool
      pngpaste # Org mode paste images
      semgrep
      nodejs_24
      terraform
      python313Packages.grip # Markdown preview
    ];

  # Needed for emacs-lsp-booster
  home.sessionVariables.LSP_USE_PLISTS = "true";
}
