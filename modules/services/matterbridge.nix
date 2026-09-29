{
  lib,
  pkgs,
  config,
  secrets,
  ...
}: {
  sops.templates."matterbridge.toml" = {
    owner = "matterbridge";
    content = ''
[telegram]
    [telegram.mytelegram]
        Token="${config.sops.placeholder.mb_tg_token}"
        RemoteNickFormat="<{NICK}> "
        MessageFormat="HTMLNick :"
        QuoteFormat="{MESSAGE} (re @{QUOTENICK}: {QUOTEMESSAGE})"
        QuoteLengthLimit=46 # Truncuate long quotes to prevent spammy bridged messages
        IgnoreMessages="^/" # Don't bridge bot commands (as the responses will not be bridged)

[irc]
    [irc.icu]
        Server="127.0.0.1:6667"
        Nick="mb-bot"
        NickServPassword="${config.sops.placeholder.mb_icu_pass}"

[[gateway]]
name="bridge-test"
enable=true

    [[gateway.inout]]
        account="telegram.mytelegram"
        channel="-5321965798"
    
    [[gateway.inout]]
        account="irc.icu"
        channel="#bridge-test"
  '';
  };
  services.matterbridge = {
    enable = true;
    package = pkgs.kkkykin.matterbridge;
    configPath = config.sops.templates."matterbridge.toml".path;
  };
}
