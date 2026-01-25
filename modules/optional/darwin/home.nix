# Darwin-specific home-manager configuration
{
  pkgs,
  ...
}:

{
  # SSH with Secretive
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      forwardAgent = true;
      extraOptions = {
        IdentityAgent = "/Users/wojtek/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
      };
    };
  };

  # GPG agent with pinentry-touchid
  home.file.".gnupg/gpg-agent.conf".text =
    "pinentry-program ${pkgs.pinentry-touchid}/bin/pinentry-touchid";

  # Gopass wrapper for browser extension
  xdg.configFile."gopass/gopass_wrapper.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      export PATH="/run/current-system/sw/bin:$PATH"
      export GPG_TTY="$(tty)"
      ${pkgs.gopass-jsonapi}/bin/gopass-jsonapi listen
      exit $?
    '';
  };

  # macOS-specific packages
  home.packages = with pkgs; [
    nixfmt-rfc-style
    coreutils-prefixed
    gopass
    gopass-jsonapi
    jdk21
  ];

  home.stateVersion = "24.05";
}
