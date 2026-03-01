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
    outputs.nixosModules.sing-box
    outputs.nixosModules.caddy
    ./hardware-configuration.nix
  ];

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.secrets.caddy.path;
  services = let
    srs-dir = "/var/lib/srs-decompile/";
  in {
    caddy = {
      globalConfig = ''
acme_dns cloudflare {env.CF_API_TOKEN}
https_port 7777
      '';
    };
    cloudflare-warp.enable = true;
    srsDecompile = {
      enable = true;
      outputDir = srs-dir;
      urls = [
        "https://github.com/SagerNet/sing-geoip/raw/refs/heads/rule-set/geoip-cn.srs"
        "https://github.com/Chocolate4U/Iran-sing-box-rules/raw/refs/heads/rule-set/geoip-cloudflare.srs"
      ];
    };
  };

  boot = {
    loader = {
      grub.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  ############### Add by reinstall.sh ###############
  boot.loader.grub.device = "/dev/vda";
  swapDevices = [{ device = "/swapfile"; size = 1076; }];
  boot.kernelParams = [ "console=ttyS0,115200n8" "console=tty0" ];
  networking = secrets.network.dmit.networking;
  systemd.network = secrets.network.dmit.systemd;
  ###################################################


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
