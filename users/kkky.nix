{
  config,
  pkgs,
  ...
}: {
  imports = [./common.nix];

  users.users.kkky = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGW5JyRHHcu6jcmH2tSQHGnWZJspvIZRkrB6XjFBFhQj openpgp:0x50A1F794"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPL37w2FQh7/LPCL32EISGASLgYale9S3r2JOgyOt5GE wireshark"
    ];
    hashedPasswordFile = config.sops.secrets.kkky_pass.path;
    packages = with pkgs; [
      czkawka
      sing-box
      kkkykin.montecarlo-ip-searcher
    ];
  };

  environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";

  # x [xpra 参数...] [--] <编号> <程序> [参数...]：在 xpra 中启动程序，HTML 端口 1451<编号>
  programs.bash.interactiveShellInit = ''
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
}
