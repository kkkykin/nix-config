# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  username,
  inputs,
  secrets,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common/server.nix
    ../../users/vps.nix
    inputs.kkkykin.nixosModules.default

    ../../modules/services/caddy.nix
    ../../modules/services/dictd.nix
    ../../modules/services/gitolite.nix
    # ../../modules/services/matrix-continuwuity.nix
    ../../modules/services/ergochat.nix
    ../../modules/services/matterbridge.nix
    ../../modules/services/mediamtx.nix
    ../../modules/services/sing-box.nix
  ];

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.secrets.caddy.path;
  services = let
    srs-dir = "/var/lib/srs-decompile/";
    dot-domain = "sting.${secrets.domain}";
    irc-domain = "icu.${secrets.domain}";
  in {
    caddy = {
      globalConfig = ''
acme_dns cloudflare {env.CF_API_TOKEN}
https_port 7777
layer4 {
    tcp/:12628 {
        @cn remote_ip_list ${srs-dir}/geoip-cn.cidr.txt
        route @cn {
            proxy {
                upstream {
                    dial tcp/127.0.0.1:2628
                    # max_connections 5
                }
            }
        }
    }
    tcp/:443 {
        @conty tls sni conty.${secrets.domain}
        route @conty {
            subroute {
                @cf remote_ip_list ${srs-dir}/geoip-cloudflare.cidr.txt
                @cone remote_ip ${lib.strings.concatStringsSep " " secrets.ips.cone}
                @dmit remote_ip ${lib.strings.concatStringsSep " " secrets.ips.dmit}
                route @cf @cone @dmit {
                    proxy 127.0.0.1:7777
                }
            }
        }

        @cf remote_ip_list ${srs-dir}/geoip-cloudflare.cidr.txt
        route @cf {
            subroute {
                @mtx tls sni mtx.${secrets.domain}
                @mtx-hls tls sni mtx-hls.${secrets.domain}
                @mb tls sni mb.${secrets.domain}
                route @mtx @mtx-hls @mb {
                  proxy 127.0.0.1:7777
                }
            }
        }
    }
    tcp/:853 {
        @dot {
            remote_ip_list ${srs-dir}/geoip-cn.cidr.txt
            tls sni ${dot-domain}
        }
        route @dot {
            tls {
                connection_policy {
                    alpn dot
                }
            }
            proxy tcp/127.0.0.1:53
        }
    }
    tcp/:6697 {
        @dot {
            remote_ip_list ${srs-dir}/geoip-cn.cidr.txt
            tls sni ${irc-domain}
        }
        route @dot {
            tls
            proxy tcp/127.0.0.1:6667 {
                proxy_protocol v1
            }
        }
    }
}
      '';
      virtualHosts = {
        "*.${secrets.domain}" = {
          extraConfig = ''
@mtx-hls host mtx-hls.${secrets.domain}
reverse_proxy @mtx-hls 127.0.0.1:8888
@mtx host mtx.${secrets.domain}
reverse_proxy @mtx 127.0.0.1:8889
          '';
        };
      };
    };
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
    kernel.sysctl."net.ipv4.ip_forward" = 1;
  };

  ############### Add by reinstall.sh ###############
  boot.loader.grub.device = "/dev/vda";
  swapDevices = [{ device = "/swapfile"; size = 1076; }];
  boot.kernelParams = [ "console=ttyS0,115200n8" "console=tty0" ];
  networking = secrets.networking;
  systemd.network = secrets.network;
  ###################################################


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
