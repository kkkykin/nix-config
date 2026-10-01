{
  pkgs,
  secrets,
  config,
  ...
}: let
  hls-addr = "127.0.0.1:8888";
  trusted-proxies = ["127.0.0.1"];
in {
  systemd.services.mediamtx.serviceConfig = {
    EnvironmentFile = config.sops.secrets.mediamtx.path;
  };
  services.mediamtx = {
    enable = true;

    settings = {
      api = false;
      metrics = false;
      authMethod = "internal";

      authInternalUsers = [
        {
          user = "argon2:$argon2id$v=19$m=4096,t=3,p=1$c2FsdEl0V2l0aFNhbHQ$OJrGw+Mp0m0o1xe2KFiLXUimnXuiAHqo5Xxgw4d3Zkc";
          pass = "argon2:$argon2id$v=19$m=4096,t=3,p=1$c2FsdEl0V2l0aFNhbHQ$Q/usgMc9kb0HEwLYc63Ivop/91PNnLcgwjfq5sQv8Gk";
          ips = [];
          permissions = [
            {
              action = "publish";
              path = "pub";
            }
          ];
        }
        {
          user = "argon2:$argon2id$v=19$m=4096,t=3,p=1$c2FsdEl0V2l0aFNhbHQ$A3MfsPlDZFqgM74FCGHwjsCR1JDhmkjbkvmQXVN/JTw";
          pass = "argon2:$argon2id$v=19$m=4096,t=3,p=1$c2FsdEl0V2l0aFNhbHQ$7WqJWcZK89SWr3TCaovKQmI/kf03PZf7ygY1KpJmQk4";
          ips = [];
          permissions = [
            {
              action = "read";
              path = "pub";
            }
          ];
        }
      ];

      rtsp = false;
      rtmp = false;
      # rtspAddress = "127.0.0.1:8554";

      srt = true;
      srtAddress = ":8890";

      hls = true;
      hlsAddress = hls-addr;
      hlsVariant = "fmp4";
      hlsAllowOrigins = ["https://hls.${secrets.domain}"];
      hlsTrustedProxies = trusted-proxies;
      hlsAlwaysRemux = false;

      webrtc = true;
      webrtcAddress = "127.0.0.1:8889";
      webrtcEncryption = false;
      webrtcAllowOrigins = ["https://mtx.${secrets.domain}"];
      webrtcTrustedProxies = trusted-proxies;
      webrtcLocalUDPAddress = ":8189";
      webrtcLocalTCPAddress = ":8189";
      webrtcIPsFromInterfaces = false;
      webrtcAdditionalHosts = ["sting.${secrets.domain}"];

      paths = {
        pub = {};
      };
    };
  };
}
