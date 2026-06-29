pkgs: {
  caddy-custom = pkgs.callPackage ./caddy-custom { };
  gpt-load = pkgs.callPackage ./gpt-load { };
  snow-ai = pkgs.callPackage ./snow-ai { };
  hubproxy = pkgs.callPackage ./hubproxy { };
  picoclaw = pkgs.callPackage ./picoclaw { };
  nullclaw = pkgs.callPackage ./nullclaw { };
}
