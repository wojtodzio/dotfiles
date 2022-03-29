{ pkgs, config, lib, ... }:

let
  pinentry-touchid = pkgs.callPackage ./pkgs/pinentry-touchid.nix {};
in {
  # environment.pathsToLink = [ "/etc/profile.d" "/share/zsh" "/info" "/share/info" "/share/man" "/etc/bash_completion.d" "/share/bash-completion/completions" "/bin" "/share/locale" ];
  imports =
    [ ./mac-config.nix ./shell.nix ./emacs.nix ./modules/overlays.nix <home-manager/nix-darwin> ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nixpkgs.config.allowUnfree = true;

  nix = {
    trustedUsers = [ "wojtek" ];

    extraOptions = ''
      keep-derivations = true
      keep-outputs = true
      experimental-features = nix-command flakes
    '';
    package = pkgs.nix;
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    binaryCaches = [ "https://nix-community.cachix.org/" ];
    binaryCachePublicKeys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  users.users.wojtek = {
    name = "wojtek";
    description = "Wojtek Wrona";
    home = "/Users/wojtek";
    shell = "${pkgs.zsh}/bin/zsh";
  };

  # Set shell to the current zsh, as /run/current-system may be not available yet when terminal windows are restored
  system.activationScripts.postActivation.text =
    "chsh -s ${pkgs.zsh}/bin/zsh wojtek";

  home-manager.users.wojtek = {
    programs = {
      git = {
        enable = true;
        package = pkgs.gitAndTools.gitFull;
        delta = {
          enable = true;
          options = {
            diff-so-fancy = true;
            line-numbers = true;
            navigate = true;
          };
        };
        userName = "Wojtek Wrona";
        userEmail = "wojtodzio@gmail.com";
        signing = {
          key = "70354561AC152EDA";
          signByDefault = true;
        };
        ignores = [ "*~" ".DS_Store" ".tab-title" ];
        extraConfig = {
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
    };

    xdg.configFile = {
      "gopass/gopass_wrapper.sh" = {
        executable = true;
        text = ''
          #!/bin/sh
          export PATH="/run/current-system/sw/bin:$PATH"
          export GPG_TTY="$(tty)"
          ${pkgs.gopass-jsonapi}/bin/gopass-jsonapi listen
          exit $?
        '';
      };
    };

    home = {
      file = {
        ".gnupg/gpg-agent.conf".text = "pinentry-program ${pinentry-touchid}/bin/pinentry-touchid";
      };

      packages = with pkgs; [
        nixfmt
        coreutils
        gopass
        gopass-jsonapi
      ];
    };
  };

  # Combine user and system packages to fix missing completions
  # https://github.com/nix-community/home-manager/issues/2562
  environment.systemPackages = with pkgs; [ gnupg ] ++ config.users.users.wojtek.packages;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  environment.shells = [ "${pkgs.zsh}/bin/zsh" ];

  services.lorri.enable = true;
  services.redis.enable = true;

  homebrew = {
    enable = true;
    autoUpdate = false;
    cleanup = "zap";
    brewPrefix = "/opt/homebrew/bin";
    casks = [
      "iterm2"
      "google-chrome"
      "slack"
      "discord"
      "mimestream"
      "toggl-track"
      "rectangle"
      "postico"
      "postgres-unofficial"
      "docker"
      "visual-studio-code"
      "postman"
      "grammarly"
      "spotify"
      "raycast"
      "bettertouchtool"
      "fantastical"
      "coconutbattery"
      "iina"
      "binance"
      "airtable"
      "zoom"
    ];

    brews = [ "phrase" ];

    masApps = {
      Irvue = 1039633667;
      Messenger = 1480068668;
      Xcode = 497799835;
      # "TV Time" = 431065232;
    };

    taps = [ "homebrew/cask" "phrase/brewed" ];
  };
}
