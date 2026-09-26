{
  config,
  secrets,
  pkgs,
  ...
}: let
  port = 8045;
  url = "http://127.0.0.1:${toString config.services.sillytavern.port}";
in {
  services = {
    sillytavern = {
      enable = true;
      whitelist = true;
      package = pkgs.sillytavern;
      port = port;
      configFile = config.sops.secrets.sillytavern.path;
    };
  };
  my.webApps.sillytavern.caddyConfig = ''
@openai {
  method POST
  path /api/openai/generate-image
  path /api/openai/generate-video
}

json_transform @openai {
  jq `.reverse_proxy = "http://127.0.0.1:4000/v1"`
}

reverse_proxy ${url} {
  flush_interval -1
}
'';
}
