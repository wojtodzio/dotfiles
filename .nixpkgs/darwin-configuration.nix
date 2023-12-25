{ pkgs, config, lib, ... }:

let
  pinentry-touchid = pkgs.callPackage ./pkgs/pinentry-touchid.nix {};
in {
  # environment.pathsToLink = [ "/etc/profile.d" "/share/zsh" "/info" "/share/info" "/share/man" "/etc/bash_completion.d" "/share/bash-completion/completions" "/bin" "/share/locale" ];
  imports =
    [ ./mac-config.nix ./shell.nix ./emacs.nix <home-manager/nix-darwin> ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      trusted-users = [ "wojtek" ];
      substituters = [ "https://nix-community.cachix.org/" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

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
      ssh.enable = true;

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
          core = {
            editor = "code --wait";
          };
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

      neovim = {
        enable = true;
        vimAlias = true;
        extraConfig = ''
          " Use system clipboard
          set clipboard+=unnamedplus

          " Copy with CMD-c
          vnoremap <D-c> "+y
          nnoremap <D-c> V"+y

          " Transform vim selection to VSCode for the Copilot Chat
          vnoremap <D-i> <Cmd>call VSCodeNotify('interactiveEditor.start', 1)<CR>

          " Transform vim selection to VSCode for the commenting lines
          vnoremap <D-/> <Cmd>call VSCodeNotify('editor.action.commentLine', 1)<CR>

          " Use VSCode's formatter
          vnoremap <=-=> <Cmd>call VSCodeNotify('editor.action.commentLine', 1)<CR>
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
        coreutils-prefixed
        gopass
        gopass-jsonapi
      ];

      stateVersion = "23.11";
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
    onActivation = {
      cleanup = "zap";
      autoUpdate = false;
    };

    enable = true;
    brewPrefix = "/opt/homebrew/bin";
    casks = [
      "iterm2"
      "mimestream" # email
      "slack"
      "discord"
      "rectangle" # window management
      "orbstack" # docker
      "visual-studio-code"
      "visual-studio-code-insiders"
      "postman"
      "grammarly"
      "spotify"
      "raycast"
      "bettertouchtool"
      "fantastical"
      "coconutbattery" # battery status with time estimation
      "battery" # preserve battery life by not charging over 80%
      "iina" # media player
      "binance" # crypto
      "airtable"
      "zoom"
      "nordvpn"
      "figma"
      "dash" # offline documentation
      "monitorcontrol"
      "utm" # virtual machines
      "kindle"
      "daisydisk" # super fast disk usage visualizer and space cleaner
      "textsniper" # copy text from screen
      "adobe-creative-cloud" # photoshop
      "garmin-express" # Garmin watch
      "tailscale"

      # db
      "postico"
      "postgres-unofficial"
      "redisinsight"

      # browsers
      "google-chrome"
      "arc"
      "orion" # WebKit (Safari) with Chrome extensions
      "firefox"

      # gaming
      "gog-galaxy"
      "epic-games"
      "steam"
      "heroic" # GOG, Amazon and Epic Games Launcher in one place
    ];

    masApps = {
      Irvue = 1039633667; # random wallpapers from Unsplash
      Messenger = 1480068668; # Facebook Messenger
      Xcode = 497799835;
      Prime = 545519333; # Prime Video
      "Hyper Duck" = 6444667067; # Share links from ios to mac when airdrop doesn't work

      # IOS apps, not supported by mas yet:
      # Pocket = 309601447; # Read it later
      # "TV Time" = 431065232; # Track TV shows
    };

    taps = [
      "homebrew/cask-versions"
    ];
  };
}
