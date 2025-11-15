{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.gpt-load;
in {
  options.services.gpt-load = {
    enable = mkEnableOption "GPT-Load AI API proxy service";

    package = mkOption {
      type = types.package;
      default = pkgs.gpt-load;
      description = "The gpt-load package to use";
    };

    port = mkOption {
      type = types.port;
      default = 3001;
      description = "Port to listen on";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Host to listen on";
    };

    extraEnvVars = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional environment variables";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to an environment file to load before starting GPT-Load.
        Useful for setting sensitive values like database passwords.
      '';
      example = "/etc/nixos/gpt-load-secrets.env";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.gpt-load = {
      description = "GPT-Load AI API Proxy Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {  
        PORT = toString cfg.port;  
        HOST = cfg.host;
      } // cfg.extraEnvVars;  

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/gpt-load";
        Restart = "on-failure";
        RestartSec = "5s";
        EnvironmentFile = mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];

        # Security hardening
        DynamicUser = true;
        StateDirectory = "gpt-load";
        WorkingDirectory = "/var/lib/gpt-load";

        # Sandboxing
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictRealtime = true;
        RestrictNamespaces = true;
        LockPersonality = true;
      };
    };
  };
}
