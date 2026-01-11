# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  username,
  outputs,
  secrets,
  ...
}: {
  imports = [
    outputs.nixosModules.all-services
    outputs.nixosModules.caddy
    outputs.nixosModules.cli-proxy-api
    outputs.nixosModules.sing-box
    outputs.nixosModules.sillytavern
    outputs.nixosModules.openlist
    # outputs.nixosModules.axonhub
    # outputs.nixosModules.gpt-load
    # outputs.nixosModules.uni-api
    outputs.nixosModules.libvirt
    outputs.nixosModules.litellm
    outputs.nixosModules.music-sync
    outputs.nixosModules.wallpaper
    outputs.nixosModules.aria2
    outputs.nixosModules.jellyfin
    outputs.nixosModules.komga
    outputs.nixosModules.fdroid
    outputs.nixosModules.freshrss
    outputs.nixosModules.tcpdump
    outputs.nixosModules.cloudflared
    ./hardware-configuration.nix
  ];
  users.users.${username} = {
    extraGroups = ["openlist"];
  };

  security.pki.certificateFiles = [
    ./mitmproxy-ca-cert.cer
  ];

  services = {
    openssh = {
      settings = {
        X11Forwarding = true;
        X11UseLocalhost = true;
      };
    };
    postgresql = {
      enable = true;
      authentication = ''
        host axonhub axonhub 127.0.0.1/32 scram-sha-256
        host gpt-load gpt-load 127.0.0.1/32 scram-sha-256
        host litellm litellm 127.0.0.1/32 scram-sha-256
        host uni-api uni-api 127.0.0.1/32 scram-sha-256
        host openlist openlist 127.0.0.1/32 scram-sha-256
        host freshrss freshrss 127.0.0.1/32 scram-sha-256
      '';
      ensureDatabases = [
        "axonhub"
        "gpt-load"
        "litellm"
        "uni-api"
        "openlist"
        "freshrss"
      ];
      ensureUsers = [
        {
          name = "axonhub";
          ensureDBOwnership = true;
        }
        {
          name = "gpt-load";
          ensureDBOwnership = true;
        }
        {
          name = "litellm";
          ensureDBOwnership = true;
        }
        {
          name = "uni-api";
          ensureDBOwnership = true;
        }
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
    };
  };
  
  environment.systemPackages = with pkgs; [
    calibre
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
