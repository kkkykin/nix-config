{pkgs, ...}: {
  imports = [
    ../../home/core.nix
    ../../home/programs
    ../../home/programs/emacs.nix
    ../../home/programs/coding-agents.nix
  ];
  home = {
    shellAliases = {
      tome2 = "tome-gcu";        # tome2
    };
    packages = with pkgs; [
      torsocks

      boohu
      cataclysmDDA.stable.curses
      (pkgs.narsil.override {
        enableSdl2 = false;
      })
      tome2
    ];
  };

  programs.bash = {
    bashrcExtra = ''
export all_proxy="socks5h://$(ip route show | grep -i default | cut -d' ' -f3):10807"
'';
  };

}
