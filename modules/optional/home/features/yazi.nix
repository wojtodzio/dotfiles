# Yazi terminal file manager configuration
{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:

let
  isDarwin = config.hostSpec.isDarwin;
  unstable = pkgsUnstable;
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "6c71385af67c71cb3d62359e94077f2e940b15df";
    sha256 = "sha256-+akz8E6Fmk6KwmeZOePEm/KqfbDaKeL4wiUgtm12SAE=";
  };
in
{
  programs.yazi = {
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
        rev = "eca186171c5f2011ce62712f95f699308251c749";
        sha256 = "sha256-xcz2+zepICZ3ji0Hm0SSUBSaEpabWUrIdG7JmxUl/ts=";
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
      ]
      ++ lib.optionals isDarwin [
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
}
