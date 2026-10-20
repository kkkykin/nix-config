{pkgs, ...}: {
  imports = [./common.nix];

  users.users.nixos.packages = with pkgs; [
    torsocks
    ripgrep
    nodejs
    bun

    boohu
    (narsil.override {enableSdl2 = false;})
  ];

  environment.shellAliases.tome2 = "tome-gcu";

  # 走 Windows 宿主机上的代理
  programs.bash.interactiveShellInit = ''
    export all_proxy="socks5h://$(ip route show | grep -i default | cut -d' ' -f3):10807"
  '';
}
