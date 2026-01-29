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
    boohu
  ];

  programs.bash = {
    bashrcExtra = ''
export all_proxy="socks5h://$(ip route show | grep -i default | cut -d' ' -f3):10807"
'';
  };

}
