{
  config,
  secrets,
  pkgs,
  username,
  ...
}:
let
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
      image = "ubuntu:24.04";
      hostUsers = [ username ];

      extraOptions = [
        "--add-host=${llm-gateway}:host-gateway"
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
