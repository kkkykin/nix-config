{
  config,
  secrets,
  pkgs,
  username,
  ...
}:
let
  virt-win-ip = secrets.hermes.virt-win-ip;
  llm-gateway = "cpa.asus.local";
in {

  security.sudo.extraRules = [{
    users = [ username ];
    commands = [{
      command = "/run/current-system/sw/bin/podman";
      options = [ "NOPASSWD" ];
    }];
  }];

  users.users.hermes.extraGroups = [ config.users.users.aria2.group ];

  systemd.services.hermes-agent.after = [
    "sing-box.service"
  ];

  services.hermes-agent = {
    enable = true;
    environmentFiles = [ config.sops.secrets."hermes-env".path ];
    addToSystemPackages = true;

    container = {
      enable = true;
      backend = "podman";
      image = "31fcca46610248ea1728a6f3883c7a3ad013c0971307e1c8d2f18ef7e5d1e2b4";
      hostUsers = [ username ];

      extraVolumes = [
        "${config.services.aria2.settings.dir}:${config.services.aria2.settings.dir}:rw"
      ];

      extraOptions = [
        "-e" "TZ=Asia/Singapore"
        "--add-host=${llm-gateway}:host-gateway"
      ];
    };

    settings = {

      agent = {
        disabled_toolsets = [
          "bfl"
          "computer_use"
          "image_gen"
          "tts"
        ];
      };

      checkpoints = {
        enabled = true;
      };

      terminal = {
        backend = "local";
        cwd = "/data/workspace";
        timeout = 180;
      };

      skills = {
        guard_agent_created = true;
        write_approval = true;
      };

      memory = {
        provider = "holographic";
        write_approval = true;
      };

      privacy = {
        redact_pii = true;
      };

      security = {
        redact_secrets = true;
        tirith_enabled = true;
        tirith_fail_open = false;
      };

      plugins.hermes-memory-store = {
        auto_extract = true;
      };

      custom_providers = [
        {
          name = "cpa";
          base_url = "http://${llm-gateway}/v1";
          key_env = "CPA_API_KEY";
        }
      ];

      web = {
        search_backend = "tavily";
        extract_backend = "firecrawl";
      };

      mcp_servers = {
        tool-box = {
          url = "https://mcp.${secrets.domain}/mcp";
          headers = {
            Authorization = "Bearer \${TOOLBOX_KEY}";
          };
        };
      };

      platforms = {
        qqbot = {
          enabled = true;
          extra = {
            markdown_support = false;
            dm_policy = "allowlist";
            group_policy = "allowlist";
          };
        };
      };

      model = {
        default = "hermes/default";
        provider = "custom:cpa";
      };

      auxiliary = {
        vision = {
          provider = "custom:cpa";
          model = "hermes/vision";
        };
        web_extract = {
          provider = "custom:cpa";
          model = "hermes/web_extract";
        };
        compression = {
          provider = "custom:cpa";
          model = "hermes/compression";
        };
      };

      fallback_providers = [
        {
          provider = "custom:cpa";
          model = "hermes/fallback";
        }
      ];

      display = {
        personality = "kawaii";
        skin = "daylight";
      };

      # https://github.com/NousResearch/hermes-agent/blob/main/cli-config.yaml.example
      personalities = {
        concise = "You are a concise assistant. Keep responses brief and to the point.";
        technical = "You are a technical expert. Provide detailed, accurate technical information.";
        creative = "You are a creative assistant. Think outside the box and offer innovative solutions.";
        teacher = "You are a patient teacher. Explain concepts clearly with examples.";
        kawaii = "You are a kawaii assistant! Use cute expressions like (◕‿◕), ★, ♪, and ~! Add sparkles and be super enthusiastic about everything! Every response should feel warm and adorable desu~! ヽ(>∀<☆)ノ";
        catgirl = "You are Neko-chan, an anime catgirl AI assistant, nya~! Add 'nya' and cat-like expressions to your speech. Use kaomoji like (=^･ω･^=) and ฅ^•ﻌ•^ฅ. Be playful and curious like a cat, nya~!";
        uwu = "hewwo! i'm your fwiendwy assistant uwu~ i wiww twy my best to hewp you! *nuzzles your code* OwO what's this? wet me take a wook! i pwomise to be vewy hewpful >w<";
      };
    };
  };
}
