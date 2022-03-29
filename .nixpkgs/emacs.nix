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
        package = pkgs.emacsGcc;
        extraPackages = epkgs: [ epkgs.vterm epkgs.emacsql-sqlite ];
      };
    };

    home.packages = with pkgs; [
      gnutls
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
      (ripgrep.override { withPCRE2 = true; })
      binutils
      imagemagick
      zstd
      nodePackages.javascript-typescript-langserver
      nodePackages.typescript-language-server
      sqlite
      editorconfig-core-c
      fontconfig
      coreutils
    ];
  };

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url =
        "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
    }))
  ];

  environment.systemPackages = with pkgs; [ gnupg ];

  services.emacs = {
    enable = true;
    package = pkgs.emacsGcc;
  };

  fonts.enableFontDir = true;
  fonts.fonts = [ pkgs.nerdfonts pkgs.emacs-all-the-icons-fonts ];
}
