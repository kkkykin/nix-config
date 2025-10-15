{pkgs, ...}: {
  imports = [
    ../../home/core.nix
    ../../home/programs
  ];

  programs.git = {
    userName = "kkky";
    userEmail = "kkkykin@foxmail.com";
  };
}
