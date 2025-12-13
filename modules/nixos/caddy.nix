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

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/mholt/caddy-l4@v0.0.0-20251001194302-2e3e6cf60b25"
        "github.com/caddyserver/replace-response@v0.0.0-20250618171559-80962887e4c6"
        "github.com/abiosoft/caddy-exec=github.com/kkkykin/caddy-exec@v0.0.0-20250930150303-c92bd5346ec8"
        "github.com/kkkykin/caddy-aria2@v1.0.0"
      ];
      hash = "sha256-8uU9WdSSGG6NevhflkpN0SkIr9dg4d+eVnzaKPGNHUA=";
    };
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
