{pkgs, ...}: {
  imports = [./common.nix];

  users.users.nixos.packages = with pkgs; [
    torsocks
    ripgrep
    codex-acp
    nodejs
    bun

    boohu
    cataclysmDDA.stable.curses
    (narsil.override {enableSdl2 = false;})
    tome2
  ];

  environment.shellAliases.tome2 = "tome-gcu";

  # 走 Windows 宿主机上的代理
  programs.bash.interactiveShellInit = ''
    export all_proxy="socks5h://$(ip route show | grep -i default | cut -d' ' -f3):10807"
  '';
}
