{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.axonhub;

  # Default configuration values
  defaultConfig = {
    server = {
      port = cfg.port;
      name = "AxonHub";
      debug = false;
      base_path = "";
      request_timeout = "30s";
      llm_request_timeout = "600s";
      trace = {
        thread_header = "AH-Thread-Id";
        trace_header = "AH-Trace-Id";
        extra_trace_headers = [];
        claude_code_trace_enabled = false;
      };
    };

    db = {
      dialect = "sqlite3";
      dsn = "${cfg.dataDir}/axonhub.db?cache=shared&_fk=1&journal_mode=WAL";
      debug = false;
    };

    cache = {
      mode = "memory";
      memory = {
        expiration = "5s";
        cleanup_interval = "10m";
      };
      redis = {
        addr = "";
        username = "";
        password = "";
        db = 0;
        expiration = "30m";
      };
    };

    log = {
      name = "axonhub";
      debug = false;
      level = cfg.logLevel;
      level_key = "level";
      time_key = "time";
      caller_key = "label";
      function_key = "";
      name_key = "logger";
      encoding = cfg.logEncoding;
      includes = [];
      excludes = [];
      output = cfg.logOutput;
      file = {
        path = "${cfg.dataDir}/logs/axonhub.log";
        max_size = 100;
        max_age = 30;
        max_backups = 10;
        local_time = true;
      };
    };

    metrics = {
      enabled = false;
      exporter = {
        type = "oltphttp";
        endpoint = "localhost:8080";
        insecure = true;
      };
    };

    dumper = {
      enabled = false;
      dump_path = "${cfg.dataDir}/dumps";
      max_size = 100;
      max_age = "24h";
      max_backups = 10;
    };

    gc = {
      cron = cfg.gcCron;
    };
  };

  # Merge user-provided extra configuration
  finalConfig = recursiveUpdate defaultConfig cfg.extraConfig;

  # Generate config file
  configFile = pkgs.writeText "axonhub-config.yml"
    (pkgs.lib.generators.toJSON {} finalConfig);
in
{
  options.services.axonhub = {
    enable = mkEnableOption "AxonHub AI Gateway and Model Hub";

    package = mkOption {
      type = types.package;
      default = pkgs.axonhub;
      defaultText = literalExpression "pkgs.axonhub";
      description = "AxonHub package to use.";
    };

    user = mkOption {
      type = types.str;
      default = "axonhub";
      description = "User account under which AxonHub runs.";
    };

    group = mkOption {
      type = types.str;
      default = "axonhub";
      description = "Group account under which AxonHub runs.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/axonhub";
      description = "Data directory for AxonHub.";
    };

    port = mkOption {
      type = types.port;
      default = 8090;
      description = "Port on which AxonHub listens.";
    };

    logLevel = mkOption {
      type = types.enum [ "debug" "info" "warn" "error" "panic" "fatal" ];
      default = "info";
      description = "Log level for AxonHub.";
    };

    logEncoding = mkOption {
      type = types.enum [ "json" "console" "console_json" ];
      default = "console";
      description = "Log encoding format.";
    };

    logOutput = mkOption {
      type = types.enum [ "stdio" "file" ];
      default = "stdio";
      description = "Log output target.";
    };

    gcCron = mkOption {
      type = types.str;
      default = "0 2 * * *";
      description = "Cron expression for garbage collection.";
      example = "0 3 * * 0";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to an environment file to load before starting AxonHub.
        Useful for setting sensitive values like database passwords.
      '';
      example = "/etc/nixos/axonhub-secrets.env";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open the firewall port for AxonHub.";
    };

    extraConfig = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        Additional configuration options for AxonHub.
        These will be merged recursively with the default configuration.
        See https://github.com/looplj/axonhub for all available options.
      '';
      example = literalExpression ''
        {
          server.debug = true;
          db = {
            dialect = "postgres";
            dsn = "postgres://axonhub:password@localhost/axonhub";
          };
          metrics.enabled = true;
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    # Create service user
    users.users = mkIf (cfg.user == "axonhub") {
      axonhub = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
        description = "AxonHub service user";
      };
    };

    users.groups = mkIf (cfg.group == "axonhub") {
      axonhub = { };
    };

    # Configure firewall
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    # Setup data directory
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/logs 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/dumps 0750 ${cfg.user} ${cfg.group} -"
    ];

    # Create systemd service
    systemd.services.axonhub = {
      description = "AxonHub AI Gateway and Model Hub";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      # preStart removed: config now managed declaratively via Nix store
      # No need to copy config file - using ${configFile} directly

      unitConfig = {
        StartLimitIntervalSec = 60;   # ✅ 注意：systemd 也建议用 ...Sec 后缀
        StartLimitBurst = 3;
      };

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${cfg.package}/bin/axonhub --config ${configFile}";

        Restart = "on-failure";
        RestartSec = 5;

        # Load environment file if provided
        EnvironmentFile = mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];

        # Set HOME for the service
        Environment = [
          "HOME=${cfg.dataDir}"
        ];

        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = cfg.dataDir;

        # Resource limits
        LimitNOFILE = 65536;
        LimitNPROC = 4096;

        # Sandboxing (uncomment if your systemd supports these)
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        PrivateMounts = true;
      };
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ ];
  };
}
