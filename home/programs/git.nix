{
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    extraConfig = {
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
  };
}
