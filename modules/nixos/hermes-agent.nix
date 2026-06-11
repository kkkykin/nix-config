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

  services.hermes-agent = {
    enable = true;
    environmentFiles = [ config.sops.secrets."hermes-env".path ];
    addToSystemPackages = true;

    container = {
      enable = true;
      backend = "podman";
      image = "localhost/hermes:latest";
      hostUsers = [ username ];

      extraOptions = [
        "--add-host=${llm-gateway}:host-gateway"
        "--add-host=virt-win:${virt-win-ip}"
      ];
    };

    settings = {
      toolsets = [ "all" ];
      terminal = { backend = "local"; timeout = 180; };

      custom_providers = [
        {
          name = "cpa";
          base_url = "http://${llm-gateway}/v1";
          key_env = "CPA_API_KEY";
        }
      ];

      browser = {
        cdp_url = "ws://${virt-win-ip}:9223";
      };

      platforms = {
        qqbot = {
          enabled = true;
          extra = {
            markdown_support = false;
            dm_policy = "open";
            group_policy = "open";
          };
        };
      };

      model = {
        default = "hermes/default";
        provider = "custom:cpa";
      };
    };
  };
}
