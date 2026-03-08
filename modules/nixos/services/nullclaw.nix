{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.nullclaw;
  format = pkgs.formats.json {};
  configFile = if cfg.configFile != null then cfg.configFile else format.generate "nullclaw.json" cfg.settings;
in {

  options.services.nullclaw = {
    enable = mkEnableOption "nullclaw AI assistant runtime";

    package = mkOption {
      type = types.package;
      default = pkgs.nullclaw;
      description = "The nullclaw package to use.";
    };

    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to an existing nullclaw configuration file. If null, generates from settings.";
      example = "/etc/nullclaw/config.json";
    };

    user = mkOption {
      type = types.str;
      default = "nullclaw";
      description = "User account under which nullclaw runs.";
    };

    group = mkOption {
      type = types.str;
      default = "nullclaw";
      description = "Group account under which nullclaw runs.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/nullclaw";
      description = "Directory for nullclaw data.";
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = format.type;
        options = {
          gateway = mkOption {
            type = types.submodule {
              options = {
                host = mkOption {
                  type = types.str;
                  default = "127.0.0.1";
                  description = "Gateway bind host.";
                };
                port = mkOption {
                  type = types.port;
                  default = 3000;
                  description = "Gateway bind port.";
                };
              };
            };
            default = {};
            description = "Gateway configuration.";
          };
        };
      };
      default = {};
      description = "nullclaw configuration in JSON format. Ignored if configFile is set.";
      example = {
        gateway = {
          host = "0.0.0.0";
          port = 8080;
        };
        providers = {
          openai = {
            api_key = "sk-...";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "nullclaw") {
      nullclaw = {
        group = cfg.group;
        isSystemUser = true;
        description = "nullclaw service user";
        home = cfg.dataDir;
        createHome = true;
      };
    };

    users.groups = mkIf (cfg.group == "nullclaw") {
      nullclaw = {};
    };

    systemd.services.nullclaw = {
      description = "nullclaw AI assistant runtime";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/nullclaw gateway";
        Restart = "always";
        RestartSec = "3s";
        WorkingDirectory = cfg.dataDir;
        # Environment = [
        #   "NULLCLAW_CONFIG=${configFile}"
        # ];
        StateDirectory = "nullclaw";
        StateDirectoryMode = "0750";
        # Security settings
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [cfg.dataDir];
      };

      # Pre-start script only when using generated config
      preStart = ''
        if [ ! -f "${cfg.dataDir}/.nullclaw/config.json" ]; then
          mkdir -p "${cfg.dataDir}/.nullclaw/"
          cp ${configFile} "${cfg.dataDir}/.nullclaw/config.json"
          chown ${cfg.user}:${cfg.group} "${cfg.dataDir}/.nullclaw/config.json"
          chmod 640 "${cfg.dataDir}/.nullclaw/config.json"
        fi
      '';
    };
  };
}
