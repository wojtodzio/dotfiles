{ config, pkgs, lib, ... }: {
  home.file = {
    # raycast = {
    #   source = ./raycast;
    #   target = ".local/bin/raycast";
    #   recursive = true;
    # };
    zfunc = {
      source = ./zfunc;
      target = ".zfunc";
      recursive = true;
    };
  };

  # xdg.enable = true;
  # xdg.configFile = {
  #   "nixpkgs/config.nix".source = ../../config.nix;
  #   karabiner = {
  #     source = ./karabiner;
  #     recursive = true;
  #   };
  #   kitty = {
  #     source = ./kitty;
  #     recursive = true;
  #   };
  # };
}
