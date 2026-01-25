{
  pkgs,
  config,
  nix-index-database,
  pkgsUnstable,
  ...
}:

{
  imports = [
    ../../modules/core/host-spec.nix
    ./system.nix
    ../../modules/optional/darwin/emacs.nix
  ];

  hostSpec = {
    isDarwin = true;
    isServer = false;
    hasGui = true;
    enableEmacs = true;
    enableNeovim = true;
    enableYazi = true;
  };

  nixpkgs.config.allowUnfree = true;

  nix.enable = false;
  determinateNix = {
    customSettings = {
      eval-cores = 0;
      extra-substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org/"
        "https://devenv.cachix.org"
        "https://nixpkgs-ruby.cachix.org"
        "https://nixpkgs-python.cachix.org"
      ];
      extra-trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nixpkgs-ruby.cachix.org-1:vrcdi50fTolOxWCZZkw0jakOnUI1T19oYJ+PRYdK4SM="
        "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
      ];
      auto-optimise-store = true;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit pkgsUnstable;
    };
  };

  users.users.wojtek = {
    name = "wojtek";
    description = "Wojtek Wrona";
    home = "/Users/wojtek";
    shell = "${pkgs.zsh}/bin/zsh";
  };

  # Set shell to zsh
  system.activationScripts.postActivation.text = "chsh -s ${pkgs.zsh}/bin/zsh wojtek";

  home-manager.users.wojtek = {
    imports = [
      nix-index-database.homeModules.default
      ../../modules/core/host-spec.nix
      ../../modules/core/home
      ../../modules/optional/home/features
      ../../modules/optional/darwin/home.nix
    ];
    hostSpec = config.hostSpec;
  };

  # Combine user and system packages to fix missing completions
  # https://github.com/nix-community/home-manager/issues/2562
  environment.systemPackages = with pkgs; [ gnupg ] ++ config.users.users.wojtek.packages;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable zsh system-wide
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };
  environment.variables.SHELL = "${pkgs.zsh}/bin/zsh";
  environment.variables.EDITOR = "emacsclient -t";
  environment.variables.VISUAL = "emacsclient -c";
  environment.extraInit = ''
    [[ -d /opt/homebrew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ] && [ -n "''${SSH_CONNECTION:-}" ] && [ "''${SHLVL:-0}" -eq 1 ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
  '';

  system.stateVersion = 4;

  environment.shells = [ "${pkgs.zsh}/bin/zsh" ];

  services.redis.enable = true;

  homebrew = {
    onActivation = {
      cleanup = "zap";
      autoUpdate = false;
    };

    enable = true;
    brewPrefix = "/opt/homebrew/bin";
    casks = [
      "iterm2"
      "itermai"
      "ghostty"
      "orbstack"
      "utm"
      "slack"
      "discord"
      "rectangle"
      "postman"
      "spotify"
      "raycast"
      "bettertouchtool"
      "fantastical"
      "coconutbattery"
      "iina"
      "binance"
      "zoom"
      "figma"
      "dash"
      "monitorcontrol"
      "kindle"
      "daisydisk"
      "textsniper"
      "garmin-express"
      "nordvpn"
      "tailscale-app"
      "balenaetcher"
      "qbittorrent"
      "stremio"
      "shottr"
      "secretive"
      "obsidian"
      "chatgpt"
      "claude"
      "claude-code"
      "visual-studio-code"
      "zed"
      "cursor"
      "texstudio"
      "mactex"
      "postico"
      "postgres-unofficial"
      "redis-insight"
      "base"
      "google-chrome"
      "arc"
      "orion"
      "firefox"
      "zen"
      "gog-galaxy"
      "epic-games"
      "steam"
      "heroic"
      "crossover"
      "moonlight"
    ];

    masApps = {
      Irvue = 1039633667;
      Xcode = 497799835;
      Prime = 545519333;
      "Hyper Duck" = 6444667067;
      Barbee = 1548711022;
    };

    taps = [
      "macos-fuse-t/homebrew-cask"
    ];
  };
}
