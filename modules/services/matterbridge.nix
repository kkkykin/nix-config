{
  lib,
  pkgs,
  config,
  secrets,
  ...
}: let
  mediaDir = "/var/cache/matterbridge/media";
in {
  users.users.caddy.extraGroups = ["matterbridge"];

  systemd.tmpfiles.rules = [
    "d /var/cache/matterbridge 0750 matterbridge matterbridge -"
    "d ${mediaDir} 2750 matterbridge matterbridge 7d"
  ];

  services.caddy.virtualHosts."*.${secrets.domain}".extraConfig = ''
    @mb-media host mb.${secrets.domain}

    basic_auth @mb-media {
      matterbridge {$MATTERBRIDGE_MEDIA_PASS}
    }

    root @mb-media ${mediaDir}
    file_server @mb-media
  '';

  sops.templates."matterbridge.toml" = {
    owner = "matterbridge";
    content = ''
      [general]
      MediaDownloadPath = "${mediaDir}"
      MediaServerDownload = "https://mb.${secrets.domain}"
      MediaDownloadSize=30000000
      RemoteNickFormat = "{NICK}/{PROTOCOL}: "

      [telegram.mytelegram]
      Token="${config.sops.placeholder.mb_tg_token}"
      MessageFormat="HTMLNick :"
      QuoteFormat="{MESSAGE} (re @{QUOTENICK}: {QUOTEMESSAGE})"
      QuoteLengthLimit=46 # Truncuate long quotes to prevent spammy bridged messages
      IgnoreMessages="^/"

      [irc.icu]
      Server="127.0.0.1:6667"
      Nick="mb-bot"
      NickServNick="mb-bot"
      NickServPassword="${config.sops.placeholder.mb_icu_pass}"
      UseSASL=true
      IgnoreMessages="^/"
      UseRelayMsg = true
      RemoteNickFormat = "{NICK}-{USERID}/{PROTOCOL}"
      ForwardChannelTimeout = 86400
      ReverseMention = true
      BotMentionTarget = "${config.sops.placeholder.mb_icu_master}"

      [onebot.qq]
      Server = "ws://${config.sops.placeholder.mb_qq_host}:3001/"
      Token = "${config.sops.placeholder.mb_qq_token}"
      AllowMention = ["users"]
      MediaDownloadSize=0


      [[gateway]]
      name="bridge-test"
      enable=true

      [[gateway.inout]]
      account="irc.icu"
      channel="#bridge-test"

      [[gateway.inout]]
      account = "onebot.qq"
      channel = "${config.sops.placeholder.mb_qq_test_channel}"

      [[gateway.inout]]
      account="telegram.mytelegram"
      channel="-5321965798"


      [[gateway]]
      name="brmk"
      enable=true

      [[gateway.inout]]
      account="irc.icu"
      channel="#brmk"

      [[gateway.inout]]
      account = "onebot.qq"
      channel = "${config.sops.placeholder.mb_qq_brmk_channel}"


      [[gateway]]
      name="catcat"
      enable=true

      [[gateway.inout]]
      account="irc.icu"
      channel="#catcat"

      [[gateway.inout]]
      account = "onebot.qq"
      channel = "${config.sops.placeholder.mb_qq_catcat_channel}"
    '';
  };
  services.matterbridge = {
    enable = true;
    package = pkgs.kkkykin.matterbridge;
    configPath = config.sops.templates."matterbridge.toml".path;
  };
}
