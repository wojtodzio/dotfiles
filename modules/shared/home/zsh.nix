# ZSH configuration shared between hosts
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Check if we're on darwin for macOS-specific config
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = false;
    defaultKeymap = "emacs";

    initContent = ''
      # Setup fzf-tab
      zstyle ':completion:*:git-checkout:*' sort false
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
      zstyle ':fzf-tab:*' switch-group ',' '.'
      zstyle ':bracketed-paste-magic' active-widgets '.self-*'

      # Explain alias or function
      '$'() {
        if [[ $(type -a "$@") =~ 'function' ]]; then
          declare -f "$@"
        else
          command -v "$@"
        fi
      }

      # Integrate fd with fzf
      _fzf_compgen_path() {
        ${pkgs.fd}/bin/fd --hidden --follow --exclude ".git" . "$1"
      }

      _fzf_compgen_dir() {
        ${pkgs.fd}/bin/fd --type d --hidden --follow --exclude ".git" . "$1"
      }

      # Ruby
      rspec() {
        if [ -e "bin/rspec" ]; then
          bin/rspec $@
        elif type bundle &> /dev/null && [ -e "Gemfile" ]; then
          bundle exec rspec $@
        else
          command rspec $@
        fi
      }

      # Utilities
      weather() {
        local city="''${1:-'Bielsko'}"
        ${pkgs.curl}/bin/curl -4 http://wttr.in/"$city"
      }

      csv() {
        column -s, -t "$1" | less -#2 -N -S
      }

      # Ghostty integration
      if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
        source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
      fi
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "common-aliases"
        "gem"
        "git-extras"
        "rails"
        "docker"
        "docker-compose"
      ]
      ++ lib.optionals isDarwin [ "macos" ];
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
      external_ip = "${pkgs.dig}/bin/dig +short myip.opendns.com @resolver1.opendns.com";
      ping8 = "ping 8.8.8.8";
      explain = "${pkgs.gh}/bin/gh copilot explain";
      suggest = "${pkgs.gh}/bin/gh copilot suggest";
      "cd.." = "cd ..";
    }
    // lib.optionalAttrs isDarwin {
      # macOS-specific aliases
      internal_ip = "ipconfig getifaddr en0";
      current_wifi_ssid = "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | sed -e 's/^  *SSID: //p' -e d";
      wifi_history = "defaults read /Library/Preferences/SystemConfiguration/com.apple.airport.preferences | grep LastConnected -A 7";
      wifi_scan = "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s";
      battery_percentage = ''pmset -g batt | egrep "([0-9]+\%).*" -o --colour=auto | cut -f1 -d";" '';
      battery_time = ''pmset -g batt | egrep "([0-9]+\%).*" -o --colour=auto | cut -f3 -d";"'';
      current_finder_path = ''osascript -e "tell app \"Finder\" to POSIX path of (insertion location as alias)"'';
    };

    shellGlobalAliases = {
      J = "| jq .";
      DS = "DISABLE_SPRING=true";
      C = "| pbcopy";
    };
  };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
