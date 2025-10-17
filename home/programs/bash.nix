{
  pkgs,
  ...
}: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
dot_rc="$(realpath ~/dotfiles/bash/_tangle/rc/general)"
[[ -x "$dot_rc" ]] && . "$dot_rc"
'';
  };
}
