{ config, pkgs, ... }:

let
  iterm2_shell_integration = pkgs.fetchFromGitHub {
    owner = "gnachman";
    repo = "iTerm2-shell-integration";
    rev = "f916547cf911629813b8a4c88183dcfd0fde4c3f";
    sha256 = "sha256-Y0qERTHwilyjYxPLZDCSRWSX6Id7MjPgDiQGh0i24Xg=";
  };
in {
  home-manager.users.wojtek = {
    programs = {
      home-manager.enable = true;
      zsh = {
        # https://github.com/nix-community/home-manager/issues/2562
        initExtraFirst = let currentSystem = "/run/current-system/sw/share/zsh"; in ''
          fpath=(
            ${currentSystem}/site-functions
            ${currentSystem}/$ZSH_VERSION/functions
            ${currentSystem}/vendor-completions
            $fpath
          )
        '';
        initExtra = ''
          # Setup fzf-tab
          ## disable sort when completing `git checkout`
          zstyle ':completion:*:git-checkout:*' sort false
          ## set descriptions format to enable group support
          zstyle ':completion:*:descriptions' format '[%d]'
          ## set list-colors to enable filename colorizing
          zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
          ## preview directory's content with exa when completing cd
          zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
          ## switch group using `,` and `.`
          zstyle ':fzf-tab:*' switch-group ',' '.'

          # Explain alias or function
          '$'() {
            if [[ $(type -a "$@") =~ 'function' ]]; then
              declare -f "$@"
            else
              command -v "$@"
            fi
          }

          # Integrate fd with fzf
          # https://github.com/sharkdp/fd#using-fd-with-fzf
          _fzf_compgen_path() {
            fd --hidden --follow --exclude ".git" . "$1"
          }

          _fzf_compgen_dir() {
            fd --type d --hidden --follow --exclude ".git" . "$1"
          }

          # Iterm itegration
          if [ $ITERM_SESSION_ID ]; then
            source ${iterm2_shell_integration + /shell_integration/zsh}
            DISABLE_AUTO_TITLE="true"

            # Set tab title to the current directory name after changing a directory
            setTabTitle() {
              echo -ne "\033];$1\007"
            }

            setTabTitlePernamently() {
              echo -n "$1" > .tab-title
            }

            setTabTitleFromPath() {
              if [ -e "$1/.tab-title" ]; then
                setTabTitle "$(cat $1/.tab-title)"
              else
                setTabTitle "''${1##*/}"
              fi
            }

            setTabTitleFromContext() {
              local git_toplevel_path="$(git rev-parse --show-toplevel 2> /dev/null)"
              if [ -n "$git_toplevel_path" ]; then
                setTabTitleFromPath "$git_toplevel_path"
              else
                setTabTitleFromPath "$PWD"
              fi
            }

            chpwd() {
              setTabTitleFromContext
            }
            setTabTitleFromContext
          fi

          # Network
          wifi_password() {
            local ssid="$1"

            security find-generic-password -D "AirPort network password" -a "$ssid" -gw
          }

          wifi_join() {
            local ssid="$1"
            local password="$2"

            networksetup -setairportnetwork en0 "$ssid" "$password"
          }
        '';
        enable = true;
        enableAutosuggestions = true;
        syntaxHighlighting.enable = true;
        enableCompletion = false;
        defaultKeymap = "emacs";
        oh-my-zsh = {
          enable = true;
          plugins = [
            "git"
            "common-aliases"
            "gem"
            "git-extras"
            "macos"
            "rails"
            "docker"
            "docker-compose"
          ];
        };
        plugins = [
          {
            name = "fzf-tab";
            file = "fzf-tab.plugin.zsh";
            src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
          }
          {
            name = "zsh-nix-shell";
            file = "nix-shell.plugin.zsh";
            src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
          }
          {
            name = "alias-tips";
            file = "alias-tips.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "djui";
              repo = "alias-tips";
              rev = "45e4e97ba4ec30c7e23296a75427964fc27fb029";
              sha256 = "URI4+TOPwTQomo+3nTmWz3BGIVOTYMhPfAvqKAt9IK8=";
            };
          }
        ];
        shellAliases = {
          path = "echo $PATH | tr ':' '\n'";
          gcwip = "OVERCOMMIT_DISABLE=1 git commit --no-verify --no-gpg-sign -m 'WIP'";
          grbma = "grbm --autostash";
          grbia = "grbi --autostash";
          external_ip = "dig +short myip.opendns.com @resolver1.opendns.com";
          internal_ip = "ipconfig getifaddr en0";
          ping8 = "ping 8.8.8.8";
          current_wifi_ssid = "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | sed -e 's/^  *SSID: //p' -e d";
          wifi_history = "defaults read /Library/Preferences/SystemConfiguration/com.apple.airport.preferences | grep LastConnected -A 7";
          wifi_scan = "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s";
          explain = "gh copilot explain";
          suggest = "gh copilot suggest";
        };
        shellGlobalAliases = {
          R = "| rg";
        };
      };

      nix-index = {
        enable = true;
        enableZshIntegration = true;
      };

      starship = {
        enable = true;
        enableZshIntegration = true;
      };

      lesspipe.enable = true;

      fzf = {
        enable = true;
        enableZshIntegration = true;
        defaultCommand = "fd --type file --follow --hidden --exclude .git --color=always";
        fileWidgetCommand = "fd --type file --follow --hidden --exclude .git --color=always";
        changeDirWidgetCommand = "fd --type directory --follow --hidden --exclude .git --color=always";
        defaultOptions = [ "--ansi" ];
      };

      bat.enable = true;

      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };

      eza = {
        enable = true;
        enableAliases = true;
      };

      gpg.enable = true;

      atuin = {
        enable = true;
        enableZshIntegration = true;
      };
    };

    home = {
      sessionPath = [
        "${iterm2_shell_integration}/utilities"
      ];
      packages = with pkgs; [
        vim
        (ripgrep.override { withPCRE2 = true; })
        fd
        gitAndTools.gitFull
        gh
        wget
        jq
        heroku
        comma # run nix commands with ,
        dogdns
        awscli2
      ];
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };

  environment.loginShell = "${pkgs.zsh}/bin/zsh -l";
  environment.variables.SHELL = "${pkgs.zsh}/bin/zsh";
  environment.variables.EDITOR = "emacsclient -t";
  environment.variables.VISUAL = "emacsclient -c";
  environment.extraInit = ''
    [[ -d /opt/homebrew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
