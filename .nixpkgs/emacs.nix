{ pkgs, config, ... }:

let
  unstable = import <unstable> {};
in {
  home-manager.users.wojtek = {
    home = {
      sessionPath = [
        "${config.home-manager.users.wojtek.home.homeDirectory}/.emacs.d/bin"
      ];
    };

    programs = {
      emacs = {
        enable = true;
        # package = pkgs.emacs29-macport;
        package = unstable.emacs30;
        extraPackages = epkgs: [
          epkgs.vterm
        ];
      };
    };

    home.packages = with pkgs; [
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
      (ripgrep.override { withPCRE2 = true; })
      coreutils-prefixed
      fd
      zstd
      jq
      semgrep # static analysis for many languages
      editorconfig-core-c
      fontconfig
      nodejs_24

      # Nix
      nil

      # vterm
      cmake
      glibtool

      # Terraform
      terraform

      # Org
      pngpaste
      graphviz

      # Docker
      dockfmt # format dockerfiles

      # Clojure
      # Disabled until https://github.com/NixOS/nixpkgs/issues/269029 is fixed
      # cljfmt # format clojure
      # clojure-lsp

      # Web
      stylelint
      jsbeautifier

      # Sh
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
      python311Packages.grip

      # Ruby
      pry
      bundix

      # lsp
      emacs-lsp-booster
    ];
  };

  environment.systemPackages = with pkgs; [ gnupg ];
  # Needed for emacs-lsp-booster
  environment.variables.LSP_USE_PLISTS = "true";
  # environment.variables.DOOMDIR = "~/dotfiles/.doom.d";

  services.emacs = {
    enable = true;
    # package = pkgs.emacs29-macport;
    package = unstable.emacs30;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    emacs-all-the-icons-fonts
  ];
}
