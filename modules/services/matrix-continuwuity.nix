{
  lib
  , pkgs
  , config
  , secrets
  , ... }:

let
  server_name = "conty.${secrets.domain}";
in {
  users.users.caddy.extraGroups = [config.services.matrix-continuwuity.group];
  services.matrix-continuwuity = {
    enable = true;
    settings = {
      global = {
        server_name = server_name;
        address = null; # Must be null when using unix_socket_path
        unix_socket_path = "/run/continuwuity/continuwuity.sock";
        unix_socket_perms = 660; # Default permissions for the socket
        well_known = {
          client = "https://${server_name}";
          server = "${server_name}:443";
        };
      };
    };
  };
}
