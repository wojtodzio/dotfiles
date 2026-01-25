{
  config,
  pkgs,
  nixSecrets,
  nix-index-database,
  pkgsUnstable,
  ...
}:

{
  imports = [
    ../../modules/core/host-spec.nix
    ./hardware-configuration.nix
    ./hardware.nix
    ./networking.nix
    ./services.nix
  ];

  hostSpec = {
    isDarwin = false;
    isServer = true;
    hasGui = false;
    enableEmacs = true;
    enableNeovim = true;
    enableYazi = true;
  };

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  # Determinate Nix configuration
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

  # User account
  users.users.wojtek = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  # Home-manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit pkgsUnstable;
    };
    users.wojtek = {
      imports = [
        nix-index-database.homeModules.default
        ../../modules/core/host-spec.nix
        ../../modules/core/home
        ../../modules/optional/home/features
        ../../modules/optional/nixos/home.nix
      ];
      hostSpec = config.hostSpec;
    };
  };

  # System packages (minimal - most come from home-manager)
  environment.systemPackages = with pkgs; [
    vim
    wget
    zellij
    git
    git-credential-manager
  ];

  # Enable zsh system-wide
  programs.zsh.enable = true;
  environment.variables.SHELL = "${pkgs.zsh}/bin/zsh";
  environment.variables.EDITOR = "emacsclient -t";
  environment.variables.VISUAL = "emacsclient -c";

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    ninja
  ];

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.git.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Do not touch
  system.stateVersion = "24.11";
}
