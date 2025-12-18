{
  config,
  secrets,
  username,
  pkgs,
  ...
}: {

  systemd.tmpfiles.rules = [
    "d ${secrets.private-www.dir} 0750 ${username} caddy -"
  ];

  systemd.services.caddy = {
    serviceConfig = {
      CapabilityBoundingSet = [
        "CAP_NET_BIND_SERVICE"
      ];
      AmbientCapabilities = [
        "CAP_NET_BIND_SERVICE"
      ];
      EnvironmentFile = config.sops.secrets.caddy.path;
    };
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy-custom;
    globalConfig = ''
${builtins.readFile ./caddy/global/servers.Caddyfile}
${builtins.readFile ./caddy/global/misc.Caddyfile}
'';
    extraConfig = ''
${builtins.readFile ./caddy/snippets/cors.Caddyfile}
${builtins.readFile ./caddy/snippets/lb.Caddyfile}
${builtins.readFile ./caddy/snippets/remove-forward-headers.Caddyfile}
'';
      virtualHosts = {
        "http://${secrets.private-www.host}:${toString secrets.private-www.port}" = {
          extraConfig = ''
file_server {
  root ${secrets.private-www.dir}
}
'';
        };
        ":80" = {
          extraConfig = ''
            encode gzip zstd

handle /aria2-redir {
    uri replace /aria2-redir /jsonrpc
    reverse_proxy http://127.0.0.1:6800
}
${builtins.readFile ./caddy/sub/aria2.Caddyfile}
${builtins.readFile ./caddy/sub/rsshub.Caddyfile}

            handle_path /jellyfin/* {
              reverse_proxy 127.0.0.1:8096
            }
          '';
        };
      };
  };
}
