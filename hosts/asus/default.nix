{
  config,
  pkgs,
  username,
  inputs,
  secrets,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common/server.nix
    ../../modules/common/web-apps.nix
    ../../users/kkky.nix

    inputs.nixos-hardware.nixosModules.asus-battery
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-disable
    inputs.nixos-hardware.nixosModules.common-pc-laptop-hdd
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    inputs.nur.modules.nixos.default
    inputs.kkkykin.nixosModules.default
    inputs.hermes-agent.nixosModules.default

    ../../modules/services/aria2.nix
    ../../modules/services/caddy.nix
    ../../modules/services/cli-proxy-api.nix
    ../../modules/services/cloudflared.nix
    ../../modules/services/fdroid.nix
    ../../modules/services/freshrss.nix
    ../../modules/services/hermes-agent.nix
    ../../modules/services/jellyfin.nix
    ../../modules/services/komga.nix
    ../../modules/services/libvirt.nix
    ../../modules/services/napcat.nix
    ../../modules/services/music-sync.nix
    ../../modules/services/openlist.nix
    ../../modules/services/podman.nix
    ../../modules/services/romm.nix
    ../../modules/services/sillytavern.nix
    ../../modules/services/sing-box.nix
    ../../modules/services/tcpdump.nix
    ../../modules/services/ungoogled-chromium.nix
  ];

  my.lanDomain = "asus.local";

  hardware = {
    asus.battery.chargeUpto = 60;
    intelgpu.vaapiDriver = "intel-media-driver";
  };

  sops.gnupg = {
    home = "/root/.gnupg";
    sshKeyPaths = [];
  };

  users.users.${username} = {
    extraGroups = ["openlist"];
  };

  security.pki.certificateFiles = [
    ./mitmproxy-ca-cert.cer
  ];

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.secrets.caddy.path;
  services = {
    caddy = {
      virtualHosts.":80".extraConfig = ''
        ${builtins.readFile ../../modules/services/caddy/sub/rsshub.Caddyfile}
        handle_path /jellyfin/* {
          reverse_proxy 127.0.0.1:8096
        }
      '';
    };
    openssh = {
      settings = {
        X11Forwarding = true;
        X11UseLocalhost = true;
      };
    };
    upower = {
      enable = true;
      percentageLow = 40;
      percentageCritical = 30;
      percentageAction = 20;
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

  networking =
    secrets.networking
    // {
      wireless = {
        enable = true;
        userControlled = true;
        secretsFile = config.sops.secrets.wireless.path;
        # generated with `wpa_passphrase ${ssid} ${password}`
        networks.ppptppo.pskRaw = "ext:psk_ppptppo";
      };
    };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  fileSystems = {
    "/".options = ["compress=zstd"];
    "/home".options = ["compress=zstd"];
    "/nix".options = ["compress=zstd" "noatime"];
    "/swap".options = ["noatime"];
    "/mnt/mediadata" = {
      label = "mediadata";
      fsType = "btrfs";
      options = ["compress=zstd" "nofail" "users" "exec"];
    };
    "/mnt/attach1" = {
      label = "attach1";
      fsType = "btrfs";
      options = ["compress=zstd" "nofail" "users"];
    };

    "/mnt/attach2" = {
      label = "attach2";
      fsType = "btrfs";
      options = ["compress=zstd" "nofail" "user" "noauto"];
    };

    "/mnt/x7music" = {
      label = "X7MUSIC";
      fsType = "vfat";
      options = ["nofail" "user" "noauto"];
    };
  };
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8 * 1024; # Creates an 8GB swap file
    }
  ];
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
