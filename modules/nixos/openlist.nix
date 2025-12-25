{
  config,
  secrets,
  ...
}: {
  services.openlist = {
    enable = true;
    envFile = config.sops.secrets.openlist.path;
  };
  services.cloudflared.tunnels."${secrets.cloudflared.asus.uuid}" = {
    ingress = {
      "openlist.${secrets.cloudflared.asus.domain}" = {
        service = "http://127.0.0.1";
        originRequest = {
          httpHostHeader = "openlist.asus.local";
        };
      };
    };
  };

  services.caddy.virtualHosts = {
    "http://openlist.asus.local" = {
      extraConfig = ''
@noStorePath path_regexp (?i)(\\.shrink_media_state\\.jsonl|\\.shrink_media_locks/.*|\\.__tmp__[^/]*$)
@noStoreMethod method PUT DELETE MOVE MKCOL PROPFIND

header @noStorePath Cache-Control "no-store, no-cache, must-revalidate"
header @noStoreMethod Cache-Control "no-store, no-cache, must-revalidate"

reverse_proxy /dav/onedrive/* http://127.0.0.1:5244
'';
    };
  };
}
