{
  username,
  pkgs,
  ...
}: let
  postReceiveHook = pkgs.writeShellScriptBin "post-receive"
    (builtins.readFile ./gitolite/post-receive);
in {
  services.gitolite = {
    enable = true;
    adminPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGW5JyRHHcu6jcmH2tSQHGnWZJspvIZRkrB6XjFBFhQj openpgp:0x50A1F794";
    extraGitoliteRc = ''
      $RC{GIT_CONFIG_KEYS} = '^(receive\.|transfer\.fsckObjects|relay\.|init\.defaultBranch).*';
    '';
    commonHooks = [
      "${postReceiveHook}/bin/post-receive"
    ];
  };
}
