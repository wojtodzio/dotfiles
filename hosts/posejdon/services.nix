{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
  services.sanoid = {
    enable = false;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      StreamLocalBindUnlink = "yes";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };
  };

  programs.mosh.enable = true;

  # Passwordless sudo when SSH'ing with keys
  security.pam.rssh.enable = true;
  security.pam.services.sudo.rssh = true;
}
