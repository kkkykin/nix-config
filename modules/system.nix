{
  pkgs,
  lib,
  username,
  ...
}: let
  lowerHttpProxy = builtins.getEnv "http_proxy";
  upperHttpProxy = builtins.getEnv "HTTP_PROXY";
  lowerHttpsProxy = builtins.getEnv "https_proxy";
  upperHttpsProxy = builtins.getEnv "HTTPS_PROXY";
  lowerAllProxy = builtins.getEnv "all_proxy";
  upperAllProxy = builtins.getEnv "ALL_PROXY";
  lowerNoProxy = builtins.getEnv "no_proxy";
  upperNoProxy = builtins.getEnv "NO_PROXY";
  mkVar = name: value: lib.optional (value != "") "${name}=${value}";
  impureEnvVars =
    mkVar "http_proxy" lowerHttpProxy
    ++ mkVar "https_proxy" lowerHttpsProxy
    ++ mkVar "all_proxy" lowerAllProxy
    ++ mkVar "no_proxy" lowerNoProxy
    ++ mkVar "HTTP_PROXY" upperHttpProxy
    ++ mkVar "HTTPS_PROXY" upperHttpsProxy
    ++ mkVar "ALL_PROXY" upperAllProxy
    ++ mkVar "NO_PROXY" upperNoProxy;
in {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = ["wheel"];
  };

  # given the users in this list the right to specify additional substituters via:
  #    1. `nixConfig.substituers` in `flake.nix`
  #    2. command line args `--options substituers http://xxx`
  nix.settings.trusted-users = [username];

  # customise /etc/nix/nix.conf declaratively via `nix.settings`
  nix.settings = {
    # enable flakes globally
    experimental-features = [
      "nix-command"
      "flakes"
      "configurable-impure-env"
    ];

    impure-env = impureEnvVars;

    substituters = [
      # cache mirror located in China
      # status: https://mirror.sjtu.edu.cn/
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      # status: https://mirrors.ustc.edu.cn/status/
      # "https://mirrors.ustc.edu.cn/nix-channels/store"

      "https://cache.nixos.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    builders-use-substitutes = true;
  };

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  programs.dconf.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    curl
    git
  ];
}
