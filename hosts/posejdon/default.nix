{
  config,
  lib,
  pkgs,
  nixSecrets,
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

  # Determinate Nix configuration
  # Note: On NixOS, determinate module uses nix.settings which gets written to /etc/nix/nix.custom.conf
  nix.settings = {
    cores = 0;
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
    system-features = [
      "nixos-test"
      "benchmark"
      "big-parallel"
      "kvm"
      "gccarch-znver4"
    ];
    trusted-users = [
      "root"
      "wojtek"
    ];
  };

  # agenix secrets configuration
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets = {
    wifi-password = {
      file = "${nixSecrets}/wifi-password.age";
      mode = "400";
      owner = "root";
    };
    posejdon-ssh-key = {
      file = "${nixSecrets}/posejdon-ssh-key.age";
      mode = "400";
      owner = "root";
    };
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.wojtek = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    zellij
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

  # Do not touch
  system.stateVersion = "24.11";
}
