# Git configuration shared between hosts
# Signing is only enabled on macOS (via Secretive)
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
  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    # Only sign commits on macOS where Secretive is available
    signing = lib.mkIf isDarwin {
      key = "70354561AC152EDA";
      signByDefault = true;
    };

    ignores = [
      "*~"
      ".DS_Store"
      ".tab-title"
    ];

    # Using new settings format (replaces userName, userEmail, extraConfig)
    settings = {
      user = {
        name = "Wojtek Wrona";
        email = "wojtodzio@gmail.com";
      };
      color.ui = "auto";
      credential."https://github.com".helper = "!gh auth git-credential";
      http.sslVerify = true;
      pull = {
        rebase = false;
        ff = "only";
      };
      init.defaultBranch = "main";
      github.user = "wojtodzio";
      rebase.autosquash = true;
      core.editor = "emacsclient -nw -r";
    };

    # https://github.com/wfxr/forgit/issues/121
    iniContent.core.pager = lib.mkForce ''
      {
        if [ $COLUMNS -ge 80 ] && [ -z $FZF_PREVIEW_COLUMNS ]; then
          ${pkgs.delta}/bin/delta --side-by-side -w $COLUMNS;
        elif [ $COLUMNS -ge 160 ] && [ ! -z $FZF_PREVIEW_COLUMNS ]; then
          ${pkgs.delta}/bin/delta --side-by-side -w $FZF_PREVIEW_COLUMNS;
        else
          ${pkgs.delta}/bin/delta;
        fi
      }
    '';
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
    options.background = "dark";
  };
}
