{
  config,
  pkgs,
  ...
}:

let
  SSID = "SUPER_DOMEK_5G";
  wirelessInterface = "wlp4s0";
in
{
  networking = {
    hostName = "posejdon";
    wireless = {
      enable = true;
      secretsFile = config.age.secrets.wifi-password.path;
      networks."${SSID}".pskRaw = "ext:psk_wifi";
      interfaces = [ wirelessInterface ];
    };

    nameservers = [
      "100.100.100.100"
      "8.8.8.8"
      "1.1.1.1"
    ];
    search = [ "halibut-dragon.ts.net" ];

    interfaces.${wirelessInterface} = {
      ipv4.addresses = [
        {
          address = "192.168.8.165";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.8.1";
      interface = wirelessInterface;
    };

    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
    };
  };

  services.tailscale = {
    enable = true;
    extraSetFlags = [
      "--ssh"
      "--advertise-exit-node"
      "--accept-routes"
      "--advertise-routes=192.168.8.0/24"
    ];
    openFirewall = true;
    useRoutingFeatures = "server";
  };

  # Disable WiFi power saving to fix inconsistent latencies
  systemd.services.disable-wifi-power-save = {
    enable = true;
    description = "Disable WiFi Power Saving";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${pkgs.iw}/bin/iw dev ${wirelessInterface} set power_save off";
  };
}
