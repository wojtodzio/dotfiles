{ config, pkgs, ... }:

let
  iterm2_shell_integration = pkgs.fetchFromGitHub {
    owner = "gnachman";
    repo = "iTerm2-shell-integration";
    rev = "f916547cf911629813b8a4c88183dcfd0fde4c3f";
    sha256 = "sha256-Y0qERTHwilyjYxPLZDCSRWSX6Id7MjPgDiQGh0i24Xg=";
  };
  unstable = pkgs.unstable;
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "600614a9dc59a12a63721738498c5541c7923873";
    sha256 = "sha256-mQkivPt9tOXom78jgvSwveF/8SD8M2XCXxGY8oijl+o=";
  };
in
{
  home-manager.users.wojtek = {
    programs = {
      home-manager.enable = true;
      zsh = {
        initContent = ''
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
          ## Fix slow pasting wiht zsh-syntax-highlighting
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
          # https://github.com/sharkdp/fd#using-fd-with-fzf
          _fzf_compgen_path() {
            ${pkgs.fd}/bin/fd --hidden --follow --exclude ".git" . "$1"
          }

          _fzf_compgen_dir() {
            ${pkgs.fd}/bin/fd --type d --hidden --follow --exclude ".git" . "$1"
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

          # Figlet fuzzy font selector with preview => copy to clipboard
          fgl() (
            [ $# -eq 0 ] && return
            cd ${pkgs.figlet}/share/figlet
            local font=$(ls *.flf | sort | ${pkgs.fzf}/bin/fzf --no-multi --reverse --preview "${pkgs.figlet}/bin/figlet -f {} $@") &&
            ${pkgs.figlet}/bin/figlet -f "$font" "$@" | pbcopy
          )

          csv() {
            column -s, -t "$1" | less -#2 -N -S
          }

          if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
            source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
          fi
        '';
        enable = true;
        autosuggestion.enable = true;
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
          external_ip = "${pkgs.dig}/bin/dig +short myip.opendns.com @resolver1.opendns.com";
          internal_ip = "ipconfig getifaddr en0";
          ping8 = "ping 8.8.8.8";
          current_wifi_ssid = "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | sed -e 's/^  *SSID: //p' -e d";
          wifi_history = "defaults read /Library/Preferences/SystemConfiguration/com.apple.airport.preferences | grep LastConnected -A 7";
          wifi_scan = "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s";
          explain = "${pkgs.gh}/bin/gh copilot explain";
          suggest = "${pkgs.gh}/bin/gh copilot suggest";
          "cd.." = "cd ..";
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

      nix-index = {
        enable = true;
        enableZshIntegration = true;
      };

      starship = {
        enable = true;
        enableZshIntegration = true;
      };

      lesspipe.enable = true; # display more with less

      zoxide.enable = true; # z - jump to directories

      # terminal file manager
      yazi = {
        enable = true;
        enableZshIntegration = true;
        shellWrapperName = "y";
        package = unstable.yazi;

        plugins = {
          chmod = "${yazi-plugins}/chmod.yazi";
          max-preview = "${yazi-plugins}/max-preview.yazi";
          smart-enter = "${yazi-plugins}/smart-enter.yazi";
          git = "${yazi-plugins}/git.yazi";
          smart-filter = "${yazi-plugins}/smart-filter.yazi";
          mime-ext = "${yazi-plugins}/mime-ext.yazi";

          starship = pkgs.fetchFromGitHub {
            owner = "Rolv-Apneseth";
            repo = "starship.yazi";
            rev = "9c37d37099455a44343f4b491d56debf97435a0e";
            sha256 = "sha256-wESy7lFWan/jTYgtKGQ3lfK69SnDZ+kDx4K1NfY4xf4=";
          };
          ouch = pkgs.fetchFromGitHub {
            owner = "ndtoan96";
            repo = "ouch.yazi";
            rev = "b8698865a0b1c7c1b65b91bcadf18441498768e6";
            sha256 = "sha256-eRjdcBJY5RHbbggnMHkcIXUF8Sj2nhD/o7+K3vD3hHY=";
          };
          what-size = pkgs.fetchFromGitHub {
            owner = "pirafrank";
            repo = "what-size.yazi";
            rev = "b23e3a4cf44ce12b81fa6be640524acbd40ad9d3";
            sha256 = "sha256-SDObD22u2XYF2BYKsdw9ZM+yJLH9xYTwSFRWIwMCi08=";
          };
          open-with-cmd = pkgs.fetchFromGitHub {
            owner = "Ape";
            repo = "open-with-cmd.yazi";
            rev = "a80d1cf41fc23f84fbdf0b8b26c5b13f06455472";
            sha256 = "sha256-IAJSZhO6WEIjSXlUvmcX3rgpQKu358vfe5dEm7JtmPg=";
          };
        };

        initLua = ''
          require("git"):setup()
          require("starship"):setup()
        '';

        settings = {
          plugin.prepend_fetchers = [
            {
              id = "git";
              name = "*";
              run = "git";
            }
            {
              id = "git";
              name = "*/";
              run = "git";
            }
            {
              id = "mime";
              "if" = "!(mime|dummy)";
              name = "*";
              run = "mime-ext";
              prio = "high";
            }
          ];

          preview.image_delay = 0;
        };

        keymap = {
          manager.prepend_keymap = [
            {
              on = [
                "c"
                "m"
              ];
              run = "plugin chmod";
              desc = "Chmod on selected files";
            }
            {
              on = "T";
              run = "plugin max-preview";
              desc = "Maximize or restore the preview pane";
            }
            {
              on = "l";
              run = "plugin smart-enter";
              desc = "Enter the child directory, or open the file";
            }
            {
              on = "F";
              run = "plugin smart-filter";
              desc = "Smart filter";
            }
            {
              on = [
                "c"
                "z"
              ];
              run = "plugin ouch --args=zip";
              desc = "Compress with ouch";
            }
            {
              on = [
                "c"
                "s"
              ];
              run = "plugin what-size";
              desc = "Calc size of selection or cwd";
            }
            {
              on = "o";
              run = "plugin open-with-cmd --args=block";
              desc = "Open with command in the terminal";
            }
            {
              on = "O";
              run = "plugin open-with-cmd";
              desc = "Open with command";
            }
            {
              on = [
                "g"
                "r"
              ];
              run = "shell 'ya emit cd \"$(git rev-parse --show-toplevel)\"'";
              desc = "Go to git root";
            }
            {
              on = "<C-p>";
              run = "shell 'qlmanage -p \"$@\"'";
              desc = "Quick look";
            }
          ];

          plugin.prepend_previewers = [
            {
              mime = "application/*zip";
              run = "ouch";
            }
            {
              mime = "application/x-tar";
              run = "ouch";
            }
            {
              mime = "application/x-bzip2";
              run = "ouch";
            }
            {
              mime = "application/x-7z-compressed";
              run = "ouch";
            }
            {
              mime = "application/x-rar";
              run = "ouch";
            }
            {
              mime = "application/x-xz";
              run = "ouch";
            }
            {
              on = "<Esc>";
              run = "close";
              desc = "Cancel input";
            }
          ];
        };
      };

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
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };

      eza.enable = true;

      gpg.enable = true;

      atuin = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          auto_sync = true;
          filter_mode = "global";
          filter_mode_shell_up_key_binding = "session";
          show_preview = true;
          secrets_filter = true;
          enter_accept = false;
        };
      };
    };

    home = {
      sessionVariables = {
        # Usage in scripts: eval $DEBUGGER
        # Note: Uses \$ to prevent evaluation at shell init (only eval when DEBUGGER is used)
        DEBUGGER = ''
          while IFS="\n" read -erp "[\$(basename \''${BASH_SOURCE[0]:-script}):\$LINENO]> " command_to_execute; do
                                 eval "\$command_to_execute";
                               done;
                               echo'';
      };

      sessionPath = [
        "${iterm2_shell_integration}/utilities"
        "$HOME/.bun/bin"
      ];
      packages = with pkgs; [
        vim
        (ripgrep.override { withPCRE2 = true; })
        fd
        gitFull
        gh
        wget
        heroku
        dogdns
        awscli2
        unixtools.watch
        speedtest-cli
        cloudflared
        p7zip
        visidata # vd https://www.visidata.org/
        timg # terminal image and video viewer.
        ouch # compression and decompression in the terminal
        jq
        jless # json viewer
        hyperfine # benchmarking tool
        sd # sed alternative
        jc # json parser
        btop # top alternative
        gping # graphical ping
        mtr # ping and traceroute
        rustscan # modern nmap
        unstable.bun
        # blender # broken on macOS in 25.11

        # nix
        nixd # lsp
        unstable.devenv
        comma # run nix commands with ,
        cachix
      ];
    };
  };

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
}
