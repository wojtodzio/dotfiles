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
      ssh = {
        enable = true;
        forwardAgent = true;
        extraConfig = ''
          IdentityAgent /Users/wojtek/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
        '';
      };

      git = {
        enable = true;
        package = pkgs.gitAndTools.gitFull;
        # delta = {
        #   enable = true;
        #   options = {
        #     diff-so-fancy = true;
        #     line-numbers = true;
        #     navigate = true;
        #   };
        # };
        difftastic = {
          enable = true;
          background = "dark";
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
            editor = "emacsclient -nw -r";
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
        ".pryrc".source = ~/dotfiles/.pryrc;
        ".psqlrc".source = ~/dotfiles/.psqlrc;
        ".doom.d/config.org".source = ~/dotfiles/.doom.d/config.org;
        ".doom.d/packages.el".source = ~/dotfiles/.doom.d/packages.el;
        ".doom.d".source = ~/dotfiles/.doom.d;
      };

      packages = with pkgs; [
        nixfmt-rfc-style
        coreutils-prefixed
        gopass
        gopass-jsonapi
        jdk21
      ];

      stateVersion = "24.05";
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
      "itermai" # iTerm2 AI Plugin
      "ghostty"
      "orbstack" # containers
      "utm" # virtual machines
      "slack"
      "discord"
      "rectangle" # window management
      "postman"
      "spotify"
      "raycast" # better spotlight
      "bettertouchtool"
      "fantastical"
      "coconutbattery" # battery status with time estimation
      "battery" # preserve battery life by not charging over 80%
      "iina" # media player
      "binance" # crypto
      "zoom"
      "figma"
      "dash" # offline documentation
      "monitorcontrol" # control your external display's brightness
      "kindle"
      "daisydisk" # super fast disk usage visualizer and space cleaner
      "textsniper" # copy text from screen
      "garmin-express" # Garmin watch
      "nordvpn"
      "tailscale"
      "balenaetcher" # flash OS images to SD cards & USB drives
      "qbittorrent" # Linux downloader
      "stremio" # Open source media center
      "shottr" # Screenshot tool
      "jordanbaird-ice" # Menu bar manager
      "secretive" # Store SSH keys in the Secure Enclave

      # LLM
      "chatgpt"
      "claude"

      # code
      "visual-studio-code"
      "zed"

      # db
      "postico"
      "postgres-unofficial"
      "redisinsight"
      "sqlitestudio"
      "db-browser-for-sqlite"

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
      "crossover"
      "moonlight"
    ];

    masApps = {
      Irvue = 1039633667; # random wallpapers from Unsplash
      Messenger = 1480068668; # Facebook Messenger
      Xcode = 497799835;
      Prime = 545519333; # Prime Video
      "Hyper Duck" = 6444667067; # Share links from ios to mac when airdrop doesn't work
      Dropover = 1355679052;
      # "Folder Hub" = 6473019059; # https://www.finderhub.app/

      # IOS apps, not supported by mas yet:
      # Pocket = 309601447; # Read it later
      # "TV Time" = 431065232; # Track TV shows
    };

    taps = [
      "homebrew/cask-versions"
      "macos-fuse-t/homebrew-cask" # FUSE for macOS that uses NFS v4 local server instead of a kernel extension
    ];
  };
}
