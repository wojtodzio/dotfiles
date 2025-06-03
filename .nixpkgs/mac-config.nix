{
  # Sudo with Touch ID
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = "wojtek";

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
      nonUS.remapTilde = true;
    };

    defaults = {
      dock.autohide = true;
      # Disable press-and-hold for keys in favor of key repeat
      NSGlobalDomain.ApplePressAndHoldEnabled = false;
      NSGlobalDomain.InitialKeyRepeat = 15;
      NSGlobalDomain.KeyRepeat = 2;
      # Text, disable automatic capitalisation
      NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
      # Text, disable smart quotes (' to `)
      NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
      # Text, disable auto-correct
      NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;

      # Do not display full path in finder
      finder._FXShowPosixPathInTitle = false;

      CustomUserPreferences = {
        "org.gnu.Emacs" = {
          "AppleFontSmoothing" = 0;
        };
      };

      # firewall
      alf.globalstate = 1;
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      loginwindow.LoginwindowText =
        "Property of Wojciech Wrona. If found, please contact wojtodzio@gmail.com or +48608035461";
    };
  };
}
