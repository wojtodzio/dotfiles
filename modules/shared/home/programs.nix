# Shared program configurations
{
  config,
  lib,
  pkgs,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;
  iterm2_shell_integration = pkgs.fetchFromGitHub {
    owner = "gnachman";
    repo = "iTerm2-shell-integration";
    rev = "f916547cf911629813b8a4c88183dcfd0fde4c3f";
    sha256 = "sha256-Y0qERTHwilyjYxPLZDCSRWSX6Id7MjPgDiQGh0i24Xg=";
  };
in
{
  programs = {
    lesspipe.enable = true;
    zoxide.enable = true;
    bat.enable = true;
    eza.enable = true;
    gpg.enable = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type file --follow --hidden --exclude .git --color=always";
      fileWidgetCommand = "fd --type file --follow --hidden --exclude .git --color=always";
      changeDirWidgetCommand = "fd --type directory --follow --hidden --exclude .git --color=always";
      defaultOptions = [ "--ansi" ];
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

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

  # Session path
  home.sessionPath = [
    "$HOME/.bun/bin"
  ]
  ++ lib.optionals isDarwin [
    "${iterm2_shell_integration}/utilities"
  ];

  # iTerm2 shell integration (macOS only)
  programs.zsh.initContent = lib.mkIf isDarwin (
    lib.mkAfter ''
      # iTerm integration
      if [ $ITERM_SESSION_ID ]; then
        source ${iterm2_shell_integration}/shell_integration/zsh
        DISABLE_AUTO_TITLE="true"

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

      # macOS Network utilities
      wifi_password() {
        local ssid="$1"
        security find-generic-password -D "AirPort network password" -a "$ssid" -gw
      }

      wifi_join() {
        local ssid="$1"
        local password="$2"
        networksetup -setairportnetwork en0 "$ssid" "$password"
      }

      # Figlet fuzzy font selector
      fgl() (
        [ $# -eq 0 ] && return
        cd ${pkgs.figlet}/share/figlet
        local font=$(ls *.flf | sort | ${pkgs.fzf}/bin/fzf --no-multi --reverse --preview "${pkgs.figlet}/bin/figlet -f {} $@") &&
        ${pkgs.figlet}/bin/figlet -f "$font" "$@" | pbcopy
      )
    ''
  );
}
