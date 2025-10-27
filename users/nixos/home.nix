{pkgs, ...}: {
  imports = [
    ../../home/core.nix
    ../../home/programs
    ../../home/programs/emacs.nix
    ../../home/programs/coding-agents.nix
  ];
  home.packages = with pkgs; [
    torsocks
    koreader
  ];

  programs.bash = {
    bashrcExtra = ''
export all_proxy="socks5h://$(ip route show | grep -i default | cut -d' ' -f3):10807"
'';
  };

  programs.git = {
    userName = "kkky";
    userEmail = "kkkykin@foxmail.com";
  };
}
