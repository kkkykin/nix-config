{
  pkgs,
  ...
}: {
  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enableBashIntegration = true;
    enableSshSupport = true;
    enable = true;
    extraConfig = ''
allow-emacs-pinentry
allow-loopback-pinentry
'';
    sshKeys = [
      "3B9C987396950F02C10B797D9E3B93358DEFD686"
    ];
  };
}
