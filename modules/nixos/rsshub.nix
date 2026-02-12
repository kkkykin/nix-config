{ ... }: {
  services.caddy = {
      virtualHosts = {
        ":80" = {
          extraConfig = ''
${builtins.readFile ./caddy/sub/rsshub.Caddyfile}
          '';
        };
      };
  };
}
