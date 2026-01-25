# Shared packages for both hosts
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
in
{
  home.packages =
    with pkgs;
    [
      # Core utilities
      vim
      (ripgrep.override { withPCRE2 = true; })
      fd
      gitFull
      gh
      wget
      curl

      # Archive/compression
      p7zip
      ouch

      # JSON tools
      jq
      jless

      # System monitoring
      btop
      htop

      # Network tools
      dig
      gping
      mtr
      speedtest-cli
      cloudflared
      dogdns

      # Development
      unstable.devenv
      unstable.bun
      direnv
      python3 # Required by alias-tips zsh plugin
      heroku
      awscli2
      terraform

      # Nix tools
      nixd
      comma
      cachix
      nixfmt-rfc-style

      # Misc utilities
      hyperfine # benchmarking
      sd # sed alternative
      jc # json parser
      figlet
      visidata
      chafa
      rustscan
    ]
    ++ lib.optionals isDarwin [
      # macOS-specific packages
      unixtools.watch
    ];
}
