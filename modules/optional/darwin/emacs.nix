# Darwin-specific emacs configuration (service, fonts)
{ pkgs, ... }:

let
  unstable = pkgs.unstable;
in
{
  # Emacs daemon service (macOS)
  services.emacs = {
    enable = true;
    package = unstable.emacs30;
  };

  # Fonts for emacs
  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    emacs-all-the-icons-fonts
  ];

  # System packages needed for emacs
  environment.systemPackages = with pkgs; [ gnupg ];
}
