{pkgs, ...}: {
  imports = [
    ../../home/core.nix
    ../../home/programs
    ../../home/programs/emacs.nix
  ];

  programs.git = {
    userName = "kkky";
    userEmail = "kkkykin@foxmail.com";
  };
}
