# Darwin-specific emacs configuration (service, fonts)
{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
lib.mkIf config.hostSpec.enableEmacs {
  # Emacs daemon service (macOS)
  services.emacs = {
    enable = true;
    package = pkgsUnstable.emacs30;
  };

  # Fonts for emacs
  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    emacs-all-the-icons-fonts
  ];

  # System packages needed for emacs
  environment.systemPackages = with pkgs; [ gnupg ];
}
