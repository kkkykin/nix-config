# 原 home-manager 配置迁移而来，个人机器（asus / legion-wsl）共用
{
  pkgs,
  username,
  ...
}: {
  users.users.${username}.packages = with pkgs; [
    _7zz-rar
    android-tools
    gopass
    mitmproxy
    rclone
    sops
    python3
    uv

    emacs-nox
    aspell
    aspellDicts.en
    tree-sitter
    gnumake
    gcc
  ];

  # ssh 使用的 keygrip 需手动写入 ~/.gnupg/sshcontrol:
  #   3B9C987396950F02C10B797D9E3B93358DEFD686
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
    settings = {
      allow-emacs-pinentry = "";
      allow-loopback-pinentry = "";
    };
  };

  programs.bash.interactiveShellInit = ''
    dot_rc="$(realpath ~/dotfiles/bash/_tangle/rc/general 2>/dev/null)"
    [[ -x "$dot_rc" ]] && . "$dot_rc"
  '';
}
