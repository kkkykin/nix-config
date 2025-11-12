{
  pkgs,
  secrets,
  ...
}: {
  environment.systemPackages = with pkgs; [
    fdroidserver
    sdkmanager
    jdk
  ];

  services.cloudflared.tunnels."${secrets.cloudflared.asus.uuid}" = {
    ingress = {
      "fdroid.${secrets.cloudflared.asus.domain}" = {
        service = "http://127.0.0.1";
        originRequest = {
          httpHostHeader = "fdroid.asus.local";
        };
      };
    };
  };

  services.caddy.virtualHosts = {
    "http://fdroid.asus.local" = {
      extraConfig = ''
root ${secrets.fdroid.dir}
@blocked {
  path /repo/status/*
}
respond @blocked 404
@allowd {
  path /repo/*
}
file_server @allowd
'';
    };
  };
}
