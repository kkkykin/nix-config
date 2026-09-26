{pkgs, ...}: {
  imports = [
    ../../home/core.nix
    ../../home/programs
    ../../home/programs/emacs.nix
    # ../../home/programs/coding-agents.nix
  ];
  home.packages = with pkgs; [
    czkawka
    sing-box
    kkkykin.montecarlo-ip-searcher
  ];

  programs.bash = {
    bashrcExtra = ''
export LIBVIRT_DEFAULT_URI=qemu:///system

x() {
    local xpra_args=()

    while [[ "$#" -gt 0 && "$1" != "--" && "$1" =~ ^- ]]; do
        xpra_args+=("$1")
        shift
    done

    [[ "$1" == "--" ]] && shift

    local no="$1"
    shift

    local prog="$1"
    shift

    local child_cmd
    printf -v child_cmd '%q ' "$prog" "$@"

    xpra start ":10''${no}" \
        "''${xpra_args[@]}" \
        --html=on \
        --bind-tcp="127.0.0.1:1451''${no}" \
        --exit-with-children=yes \
        --start-child="$child_cmd"
}
'';
  };

}
