{ pkgs, config, ... }:

{

  home-manager.users.wojtek = {
    home = {
      sessionPath = [
        "${config.home-manager.users.wojtek.home.homeDirectory}/.emacs.d/bin"
      ];
    };

    programs = {
      emacs = {
        enable = true;
        package = pkgs.emacs29-macport;
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
      nodejs_18

      # Nix
      rnix-lsp
      nil

      # vterm
      cmake

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
      ruby-lsp
      rubyPackages.solargraph
      rubyPackages.syntax_tree
      rubyPackages.sorbet-runtime
    ];
  };

  environment.systemPackages = with pkgs; [ gnupg ];

  services.emacs = {
    enable = true;
    package = pkgs.emacs29-macport;
  };

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    nerdfonts
    emacs-all-the-icons-fonts
  ];
}
