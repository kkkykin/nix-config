{pkgs, ...}: {
  imports = [
    ../../home/core.nix
    ../../home/programs
    ../../home/programs/emacs.nix
    ../../home/programs/coding-agents.nix
  ];
  home.packages = with pkgs; [
    torsocks
  ];

  programs.git = {
    userName = "kkky";
    userEmail = "kkkykin@foxmail.com";
  };
}
