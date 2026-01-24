# Shared packages for both hosts
{
  config,
  lib,
  pkgs,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;
  unstable = pkgs.unstable;
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

      # Development
      unstable.devenv
      direnv
      python3 # Required by alias-tips zsh plugin

      # Nix tools
      nixd
      comma
      cachix

      # Misc utilities
      hyperfine # benchmarking
      sd # sed alternative
      jc # json parser
      figlet
    ]
    ++ lib.optionals isDarwin [
      # macOS-specific packages
      heroku
      dogdns
      awscli2
      unixtools.watch
      cloudflared
      visidata
      timg
      rustscan
      unstable.bun
    ];
}
