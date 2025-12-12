{
  config,
  secrets,
  username,
  pkgs,
  lib,
  ...
}: let

  litellm-otel = pkgs.python3.withPackages (ps: with ps; [
    (ps.litellm.overridePythonAttrs (old: {
      propagatedBuildInputs =
        (old.propagatedBuildInputs or [])
        ++ (old.optional-dependencies.proxy or []);
    }))
    ps.opentelemetry-api
    ps.opentelemetry-sdk
    ps.opentelemetry-exporter-otlp
  ]);

in {
  systemd.tmpfiles.rules = [
    "d /etc/litellm 0750 ${username} litellm -"
  ];
  systemd.services.litellm = {
    serviceConfig.ExecStart =
      lib.mkForce "${litellm-otel}/bin/litellm --host \"${config.services.litellm.host}\" --port ${toString config.services.litellm.port} --config \"/etc/litellm/config.json\"";
  };

  services = {
    litellm = {
      enable = true;
      port = 4000;
      environment = {
        # https://github.com/NixOS/nixpkgs/issues/432925
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
