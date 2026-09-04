{
  pkgs,
  secrets,
  ...
}: let
  hls-addr = "127.0.0.1:8888";
in {
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
          ips = [ ];
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
          ips = [ ];
          permissions = [
            {
              action = "read";
              path = "pub";
            }
          ];
        }
      ];

      rtsp = false;
      # rtspAddress = "127.0.0.1:8554";

      srt = false;
      # srtAddress = ":8890";
      # srtPublishPassphrase = "argon2:$argon2id$v=19$m=4096,t=3,p=1$c2FsdEl0V2l0aFNhbHQ$zc8vgQegKhFcXV8agd70bsSAU604NpUzj+BPVY2itAg";
      # srtReadPassphrase = "argon2:$argon2id$v=19$m=4096,t=3,p=1$c2FsdEl0V2l0aFNhbHQ$MVN0UUlchGPaaCWfdUbJxpXOPViZeJsdingP6pD6BxI";

      hls = false;
      hlsAddress = hls-addr;
      hlsVariant = "lowLatency";

      webrtc = true;
      webrtcAddress = "127.0.0.1:8889";
      webrtcEncryption = false;
      webrtcAllowOrigins = [ "https://mtx.${secrets.domain}" ];
      webrtcTrustedProxies = [ "127.0.0.1" ];
      webrtcLocalUDPAddress = ":8189";
      webrtcLocalTCPAddress = ":8189";
      webrtcIPsFromInterfaces = false;
      webrtcAdditionalHosts = [ "sting.${secrets.domain}" ];

      paths = {
        pub = { };
      };
    };
  };
}
