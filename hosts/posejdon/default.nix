{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ./networking.nix
    ./services.nix
  ];

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.wojtek = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  environment.etc."ssh/authorized_keys.d/wojtek".text = ''
    ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCiLso/yPkylc0dHDhRe38kbUof5ud91BMHiWuTmzXSTfihMYjsdUoBh/d4uOp7DRl6gU+FEQoVnAnfZFQTiJ4A= Posejdon-sudo@secretive.Wojciech's-MacBook-Pro.local
  '';

  environment.systemPackages = with pkgs; [
    vim
    wget
    zellij
    pkgs.unstable.devenv
    direnv
    git
    git-credential-manager
  ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    ninja
  ];

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.zsh.enable = true;
  programs.git.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    system-features = [
      "nixos-test"
      "benchmark"
      "big-parallel"
      "kvm"
      "gccarch-znver4"
    ];
    experimental-features = [ "nix-command" ];
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    trusted-users = [
      "root"
      "wojtek"
    ];
  };

  # Do not touch
  system.stateVersion = "24.11";
}
