{
  config,
  secrets,
  username,
  pkgs,
  ...
}: {

  systemd.services.caddy = {
    serviceConfig = {
      CapabilityBoundingSet = [
        "CAP_NET_BIND_SERVICE"
      ];
      AmbientCapabilities = [
        "CAP_NET_BIND_SERVICE"
      ];
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
  };
}
