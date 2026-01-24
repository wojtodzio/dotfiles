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

  # SSH authorized keys in /etc for pam_rssh compatibility
  # pam_rssh looks in /etc/ssh/authorized_keys.d/$user by default
  environment.etc."ssh/authorized_keys.d/wojtek".source = config.age.secrets.posejdon-ssh-key.path;
}
