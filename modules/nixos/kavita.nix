{
  pkgs,
  secrets,
  config,
  ...
}: let
  kosync-fix = ''
@koreaderProgress {
  method GET
  header Accept application/vnd.koreader.v1+json
  path /api/koreader/*/syncs/progress/*
}

replace @koreaderProgress {
  re "(\"progress\":\"/body/DocFragment\[\d+\])/.*\"" "$1.0\""
}
'';
in {
  services.cloudflared.tunnels."${secrets.cloudflared.asus.uuid}" = {
    ingress = {
      "kavita.${secrets.cloudflared.asus.domain}" = {
        service = "http://127.0.0.1";
        originRequest = {
          httpHostHeader = "kavita.asus.local";
        };
      };
    };
  };

  services.caddy.virtualHosts.":80".extraConfig = ''
reverse_proxy /api/* http://127.0.0.1:5000 {
  header_up Accept-Encoding "identity"
}
${kosync-fix}
'';

  services.caddy.virtualHosts."http://kavita.asus.local" = {
    extraConfig = ''
reverse_proxy http://127.0.0.1:5000 {
  header_up Accept-Encoding "identity"
}
${kosync-fix}
'';
  };
  services.kavita = {
    enable = true;
    package = pkgs.unstable.kavita;
    tokenKeyFile = config.sops.secrets.kavita.path;
  };
}
