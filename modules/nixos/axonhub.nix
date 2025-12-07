{
  config,
  secrets,
  ...
}: {
  services = {
    axonhub = {
      enable = true;
      environmentFile = config.sops.secrets.axonhub.path;
      extraConfig = {
        server.trace.claude_code_trace_enabled = true;
      };
    };
  };

  services.cloudflared.tunnels."${secrets.cloudflared.asus.uuid}" = {
    ingress = {
      "axonhub.${secrets.cloudflared.asus.domain}" = {
        service = "http://127.0.0.1";
        originRequest = {
          httpHostHeader = "axonhub.asus.local";
        };
      };
    };
  };

  services.caddy.virtualHosts = {
    "http://axonhub.asus.local" = {
      extraConfig = ''
reverse_proxy http://127.0.0.1:${toString config.services.axonhub.port} {
  import remove-forward-headers
}
'';
    };
  };
}
