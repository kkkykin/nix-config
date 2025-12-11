{
  config,
  secrets,
  username,
  pkgs,
  lib,
  ...
}: {
  systemd.tmpfiles.rules = [
    "d /etc/litellm 0750 ${username} litellm -"
  ];
  systemd.services.litellm = {
    serviceConfig.ExecStart =
      lib.mkForce "${pkgs.litellm}/bin/litellm --host \"${config.services.litellm.host}\" --port ${toString config.services.litellm.port} --config \"/etc/litellm/config.json\"";
  };

  services = {
    litellm = {
      enable = true;
      port = 4000;
      environment = {
        DISABLE_ADMIN_UI = "True";
      };
      environmentFile = config.sops.secrets.litellm.path;
    };
  };

  services.cloudflared.tunnels."${secrets.cloudflared.asus.uuid}" = {
    ingress = {
      "litellm.${secrets.cloudflared.asus.domain}" = {
        service = "http://127.0.0.1";
        originRequest = {
          httpHostHeader = "litellm.asus.local";
        };
      };
    };
  };

  services.caddy.virtualHosts = {
    "http://litellm.asus.local" = {
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString config.services.litellm.port}
      '';
    };
  };
}
