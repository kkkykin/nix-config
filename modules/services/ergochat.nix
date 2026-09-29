{
  lib,
  pkgs,
  config,
  secrets,
  ...
}: let
  server-name = "icu.${secrets.domain}";
in {
  systemd.services.ergochat.serviceConfig = {
    EnvironmentFile = config.sops.secrets.ergochat.path;
  };
  services.ergochat = {
    enable = true;
    settings = {
      allow-environment-overrides = true;
      accounts = {
        registration = {
          enabled = false;
        };
        require-sasl = {
          enabled = true;
          exempted = [
            "localhost"
          ];
        };
      };
      oper-classes = {
        chat-moderator = {
          title = "Chat Moderator";
          capabilities = [
            "kill"
            "ban"
            "nofakelag"
            "relaymsg"
            "vhosts"
            "sajoin"
            "samode"
            "snomasks"
            "roleplay"
          ];
        };
        server-admin = {
          title = "Server Admin";
          extends = "chat-moderator";
          capabilities = [
            "rehash"
            "accreg"
            "chanreg"
            "history"
            "defcon"
            "massmessage"
            "metadata"
          ];
        };
      };
      opers = {
        admin = {
          class = "server-admin";
        };
      };
      datastore = {
        sqlite = {
          enabled = true;
          database-path = "/var/lib/ergo/ergo_history.db";
          busy-timeout = "5s";
          max-conns = 1;
        };
      };
      history = {
        retention = {
          allow-individual-delete = true;
          enable-account-indexing = true;
        };
        persistent = {
          enabled = true;
          unregistered-channels = false;
          registered-channels = "opt-out";
          direct-messages = "opt-out";
        };
      };
      roleplay.enabled = true;
      network = {
        name = "dadada";
      };
      server = {
        name = server-name;
        casemapping = "ascii";
        check-ident = true;
        lookup-hostnames = true;
        forward-confirm-hostnames = true;
        ip-cloaking = {
          enabled = true;
          netname = server-name;
        };
        relaymsg.enabled = true;
      };
    };
  };
}
