# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/sing-box.nix
    ../../modules/aria2.nix
    ../../modules/openlist.nix
    ../../modules/jellyfin.nix
    ../../modules/kavita.nix
    ../../modules/komga.nix
    ../../modules/tcpdump.nix
    ../../modules/cloudflared.nix
    ./hardware-configuration.nix
  ];
  sops = {
    defaultSopsFile = ../../secrets/asus.yaml;
    secrets = {
      "freshrss_user_pass" = {
        owner = "freshrss";
      };
      "freshrss_db_pass" = {
        owner = "freshrss";
      };
      "postgresql_init_script" = {
        owner = "postgres";
      };
      wireless = {
        sopsFile = ../../secrets/wireless.env;
        key = "";
        format = "dotenv";
      };
      openlist = {
        sopsFile = ../../secrets/openlist.env;
        key = "";
        format = "dotenv";
      };
    };
  };

  services = {
    caddy = {
      enable = true;
      package = pkgs.unstable.caddy.withPlugins {
        plugins = [
          "github.com/mholt/caddy-l4@v0.0.0-20251001194302-2e3e6cf60b25"
          "github.com/caddyserver/replace-response@v0.0.0-20250618171559-80962887e4c6"
          "github.com/abiosoft/caddy-exec=github.com/kkkykin/caddy-exec@v0.0.0-20250930150303-c92bd5346ec8"
          "github.com/kkkykin/caddy-aria2@v1.0.0"
        ];
        hash = "sha256-bWtwL339DbF272I7eFrLTWJJOvqIRp/H3AdGOBFKJrU=";
      };
      globalConfig = ''
${builtins.readFile ./caddy/global/misc.Caddyfile}
      '';
      extraConfig = ''
${builtins.readFile ./caddy/snippets/cors.Caddyfile}
${builtins.readFile ./caddy/snippets/lb.Caddyfile}
'';
      virtualHosts = {
        ":80" = {
          extraConfig = ''
            encode gzip zstd

handle /aria2-redir {
    uri replace /aria2-redir /jsonrpc
    reverse_proxy http://127.0.0.1:6800
}
${builtins.readFile ./caddy/sub/aria2.Caddyfile}
${builtins.readFile ./caddy/sub/rsshub.Caddyfile}

            handle_path /jellyfin/* {
              reverse_proxy 127.0.0.1:8096
            }

    # 1. 处理 /fdroid/archive/ 前缀
    handle_path /fdroid/archive/* {
        root * /var/www/fdroid/archive
        file_server
    }

    # 2. 处理 /fdroid/repo/ 前缀
    handle_path /fdroid/repo/* {
        root * /var/www/fdroid/repo
        # 先在本目录找，找不到就“内部重写”到 /fdroid/archive/同一文件
        try_files {path} /fdroid/archive/{file}
        file_server
    }

reverse_proxy /dav/public/* 127.0.0.1:5244
          '';
        };
      };
    };

    freshrss = {
      enable = true;
      package = pkgs.unstable.freshrss;
      webserver = "caddy";
      defaultUser = "kkky";
      passwordFile = config.sops.secrets."freshrss_user_pass".path;
      baseUrl = "http://127.0.0.1";
      virtualHost = ":80";
      language = "en";
      database = {
        type = "pgsql";
        name = "freshrss";
        user = "freshrss";
        host = "127.0.0.1";
        port = 5432;
        passFile = config.sops.secrets."freshrss_db_pass".path;
      };
    };
    openlist = {
      enable = true;
      envFile = config.sops.secrets.openlist.path;
    };
    openssh = {
      settings = {
        X11Forwarding = true;
        X11UseLocalhost = true;
      };
    };
    postgresql = {
      enable = true;
      authentication = ''
        host openlist openlist 127.0.0.1/32 scram-sha-256
        host freshrss freshrss 127.0.0.1/32 scram-sha-256
      '';
      ensureDatabases = [
        "openlist"
        "freshrss"
      ];
      ensureUsers = [
        {
          name = "openlist";
          ensureDBOwnership = true;
        }
        {
          name = "freshrss";
          ensureDBOwnership = true;
        }
      ];
      extensions = ps: with ps; [
        plpython3
      ];
      initialScript = config.sops.secrets."postgresql_init_script".path;
    };
  };
  
  environment.systemPackages = with pkgs; [
    calibre
    p7zip
  ];

  fonts = {
    packages = with pkgs; [
      lxgw-wenkai
    ];
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        5244
        9089
      ];
    };
    wireless = {
      enable = true;
      userControlled.enable = true;
      secretsFile = config.sops.secrets.wireless.path;
      # generated with `wpa_passphrase ${ssid} ${password}`
      networks.ppptppo.pskRaw = "ext:psk_ppptppo";
    };
    hostName = "asus";
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [ "compress=zstd" "noatime" ];
    "/swap".options = [ "noatime" ];
    "/mnt/mediadata" = {
      label = "mediadata";
      fsType = "btrfs";
      options = [ "compress=zstd" "nofail" "users" "exec" ];
    };
    "/mnt/attach1" = {
      label = "attach1";
      fsType = "btrfs";
      options = [ "compress=zstd" "nofail" "users" ];
    };

    "/mnt/attach2" = {
      label = "attach2";
      fsType = "btrfs";
      options = [ "compress=zstd" "nofail" "user" "noauto" ];
    };

    "/mnt/x7music" = {
      label = "X7MUSIC";
      fsType = "vfat";
      options = [ "nofail" "user" "noauto" ];
    };
  };
  swapDevices = [{
    device = "/swap/swapfile";
    size = 8*1024; # Creates an 8GB swap file
  }];
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
