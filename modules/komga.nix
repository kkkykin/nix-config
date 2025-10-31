{
  pkgs,
  secrets,
  config,
  ...
}: let
  backend = "http://127.0.0.1:25600";
  kosync-fix = ''
@koreaderSync {
  header Content-Type "application/vnd.koreader.v1+json"
  path /koreader/syncs/progress/*
}

reverse_proxy @koreaderSync ${backend} {
  header_down Content-Type application/json
}
'';
in {
  services.caddy.virtualHosts."http://komga.asus.local" = {
    extraConfig = ''
${kosync-fix}
reverse_proxy ${backend}
'';
  };
  services.komga = {
    enable = true;
    settings = {
      server = {
        port = 25600;
      };
    };
  };
}
