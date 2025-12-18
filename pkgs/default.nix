pkgs: {
  axonhub = pkgs.callPackage ./axonhub { };
  caddy-custom = pkgs.callPackage ./caddy-custom { };
  gpt-load = pkgs.callPackage ./gpt-load { };
  snow-ai = pkgs.callPackage ./snow-ai { };
  cli-proxy-api = pkgs.callPackage ./cli-proxy-api { };
}
