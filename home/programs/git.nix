{
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "kkkykin@foxmail.com";
        name = "kkky";
      };
      init = {
        defaultBranch = "main";
      };
      diff = {
        gpg = {
          textconv = "gpg -d -q";
        };
      };
      merge = {
        tool = "vimdiff";
      };
      pull = {
        ff = "only";
      };
    };
    attributes = [
      "*.gpg diff=gpg"
    ];
  };
}
