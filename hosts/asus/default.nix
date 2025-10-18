# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/system.nix
    ../../modules/server.nix
    ../../modules/nixpkgs.nix
    ../../modules/sing-box.nix
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
    };
  };

  services = {
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

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 6800 ];
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
