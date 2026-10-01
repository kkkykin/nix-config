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
        login-via-pass-command = true;
        registration = {
          enabled = false;
        };
        nick-reservation = {
          enabled = true;
          allow-custom-enforcement = false;
          method = "strict";
          force-nick-equals-account = true;
        };
        require-sasl = {
          enabled = true;
        };
      };
      fakelag = {
        enabled = true;
        window = "1s";
        burst-limit = 5;
        messages-per-window = 2;
        cooldown = "2s";
        command-budgets = {
          CHATHISTORY = 16;
          MARKREAD = 16;
          MONITOR = 1;
          WHO = 4;
          WEBPUSH = 1;
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
        daily = {
          class = "chat-moderator";
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
        autoreplay-on-join = 100;
        chathistory-maxmessages = 1000;
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
      network = {
        name = "dadada";
      };
      server = {
        name = server-name;
        casemapping = "precis";
        check-ident = true;
        lookup-hostnames = true;
        proxy-allowed-from = [
          "localhost"
        ];
        forward-confirm-hostnames = true;
        ip-cloaking = {
          enabled = true;
          netname = server-name;
        };
        relaymsg = {
          enabled = true;
          separators = "/";
          available-to-chanops = true;
        };
      };
    };
  };
}
