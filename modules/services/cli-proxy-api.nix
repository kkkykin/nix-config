{
  config,
  secrets,
  username,
  pkgs,
  ...
}: let
  llm-filter = ''
    llm_privacy_filter {
    	api auto
    	gitleaks_toml https://raw.githubusercontent.com/gitleaks/gitleaks/refs/heads/master/config/gitleaks.toml
    	gitleaks_toml_refresh_interval 1h
    	max_body_size 8388608
    	fail_open false
    }
  '';
  reverse-proxy-cpa = ''
    request_header @claude x-opencode-session {header.X-Claude-Code-Session-Id}
    request_header @codex x-opencode-session {header.session-id}
    request_header @dsh x-opencode-session {header.x-deepseek-harness-session-id}

    reverse_proxy http://127.0.0.1:8317 {
        import remove-forward-headers
        flush_interval -1
    }
  '';
in {
  users.users.${username} = {
    extraGroups = ["cli-proxy-api"];
  };

  environment.systemPackages = with pkgs; [
    nur.repos.xddxdd.cliproxyapi
  ];

  services = {
    cpa-manager-plus = {
      enable = true;
      listenAddress = "127.0.0.1:18317";
      dataDir = "/var/lib/cpa-manager-plus";
      package = pkgs.kkkykin.cpa-manager-plus;
      environmentFile = config.sops.secrets.cli-proxy-api.path;
    };
    cli-proxy-api = {
      enable = true;
      configFile = "${config.services.cli-proxy-api.homeDir}/config.yaml";
      # environmentFile = config.sops.secrets.cli-proxy-api.path;
    };
  };

  my.webApps.cpa = {
    serverAliases = [
      "http://cpa.opencode.ai"
    ];
    # https://github.com/aftely1337/amp-free-proxy
    caddyConfig = ''
      @proxy {
          header X-Proxy-Key "{$X_PROXY_KEY}"
          header X-Proxy-Upstream http*
      }

      handle @proxy {
          route /v1/* {
              ${llm-filter}
              import trans-forward
          }
          handle_path /raw/* {
              import trans-forward
          }
      }

      @codex header session-id *
      @claude header X-Claude-Code-Session-Id *
      @dsh header x-deepseek-harness-session-id *

      route /v1/* {
          ${reverse-proxy-cpa}
      }

      handle_path /raw/* {
          request_header x-vibeguard-skip true
          ${reverse-proxy-cpa}
      }
    '';
  };
}
