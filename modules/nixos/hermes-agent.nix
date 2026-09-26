{
  config,
  secrets,
  pkgs,
  username,
  lib,
  ...
}:
let
  virt-win-ip = secrets.hermes.virt-win-ip;
  llm-gateway = "cpa.opencode.ai";
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
    environment = {
      PATH = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:"
      + lib.makeBinPath [
        pkgs.fdroidserver
        pkgs.emacs-nox
        pkgs.rclone
        pkgs.nix
        pkgs.jq
        pkgs.gitleaks
        pkgs.neovim
        pkgs.czkawka
        pkgs.lua
        pkgs.stylua
      ];
    };
    addToSystemPackages = true;

    container = {
      enable = true;
      backend = "podman";
      image = "e17c1ace92aa1395e419047c80a6bd9b684a3c42fac3421abb6896108b2e5ab9";
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
        disabled = [
          "1password"
          "3-statement-model"
          "accelerate"
          "actual-setup"
          "adversarial-ux-test"
          "agentmail"
          "airtable"
          "antigravity-cli"
          "architecture-diagram"
          "arxiv"
          "ascii-art"
          "ascii-video"
          "ast-grep"
          "audiocraft-audio-generation"
          "axolotl"
          "baoyu-article-illustrator"
          "baoyu-comic"
          "baoyu-infographic"
          "bioinformatics"
          "blackbox"
          "blocked-page-recovery"
          "blogwatcher"
          "box"
          "canvas"
          "chroma"
          "claude-design"
          "clip"
          "code-wiki"
          "codebase-inspection"
          "comfyui"
          "competitor-news-monitor"
          "comps-analysis"
          "computer-use"
          "concept-diagrams"
          "creative-ideation"
          "darwinian-evolver"
          "dcf-model"
          "design-md"
          "docker-management"
          "document-to-action-items"
          "docx"
          "dogfood"
          "domain-intel"
          "draw-your-font"
          "drug-discovery"
          "dspy"
          "duckduckgo-search"
          "email-inbox-triage"
          "evaluating-llms-harness"
          "evm"
          "excalidraw"
          "excel-author"
          "faiss"
          "fastmcp"
          "fitness-nutrition"
          "flash-attention"
          "gif-search"
          "github-auth"
          "github-code-review"
          "github-issue-to-pr"
          "github-issues"
          "github-pr-workflow"
          "github-repo-management"
          "gitnexus-explorer"
          "godmode"
          "google-workspace"
          "grok"
          "grounded-citations"
          "guidance"
          "har-derived-api-client"
          "heartmula"
          "here-now"
          "hermes-s6-container-supervision"
          "himalaya"
          "honcho"
          "huggingface-hub"
          "huggingface-tokenizers"
          "humanizer"
          "hyperframes"
          "hyperliquid"
          "inference-sh-cli"
          "inspecting-hermes-desktop-dom"
          "instructor"
          "jupyter-live-kernel"
          "jupyter-notebook"
          "kanban-video-orchestrator"
          "lambda-labs"
          "lbo-model"
          "llama-cpp"
          "llava"
          "llm-wiki"
          "manim-video"
          "maps"
          "mcp-oauth-remote-gateway"
          "mcporter"
          "meeting-action-items"
          "meme-generation"
          "memento-flashcards"
          "merge-reconciler"
          "merger-model"
          "minecraft-modpack-server"
          "modal"
          "mpp-agent"
          "nano-pdf"
          "nemo-curator"
          "neuroskill-bci"
          "node-inspect-debugger"
          "notion"
          "obliteratus"
          "obsidian"
          "ocr-and-documents"
          "one-three-one-rule"
          "openclaw-migration"
          "opencode"
          "openhands"
          "openhue"
          "osint-investigation"
          "oss-forensics"
          "outlines"
          "p5js"
          "page-agent"
          "parallel-cli"
          "pdf"
          "peft"
          "pinecone"
          "pinecone-research"
          "pinggy-tunnel"
          "pixel-art"
          "plan"
          "pokemon-player"
          "polymarket"
          "popular-web-designs"
          "powerpoint"
          "pptx-author"
          "pretext"
          "product-price-monitor"
          "python-debugpy"
          "pytorch-fsdp"
          "pytorch-lightning"
          "qdrant"
          "qmd"
          "requesting-code-review"
          "research-paper-writing"
          "rest-graphql-debug"
          "saelens"
          "scrapling"
          "sdlc-review"
          "searxng-search"
          "segment-anything-model"
          "serving-llms-vllm"
          "sherlock"
          "shop"
          "shopify"
          "simple-english"
          "simplify-code"
          "simpo"
          "siyuan"
          "sketch"
          "slime"
          "social-media-content-calendar"
          "solana"
          "songsee"
          "songwriting-and-ai-music"
          "spike"
          "stable-diffusion"
          "stocks"
          "stripe-link-cli"
          "stripe-projects"
          "subagent-driven-development"
          "systematic-debugging"
          "teams-meeting-pipeline"
          "telephony"
          "tensorrt-llm"
          "test-driven-development"
          "tldraw-offline"
          "torchtitan"
          "touchdesigner-mcp"
          "trl-fine-tuning"
          "unbroker"
          "unreal-mcp"
          "unsloth"
          "watchers"
          "web-pentest"
          "weekly-review-planning"
          "weights-and-biases"
          "whisper"
          "xlsx"
          "xurl"
          "youtube-content"
          "yuanbao"
        ];
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
          base_url = "http://${llm-gateway}";
          key_env = "CPA_API_KEY";
          api_mode = "anthropic_messages";
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
