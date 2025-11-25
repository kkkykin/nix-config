pkgs: {
  axonhub = pkgs.callPackage ./axonhub { };
  gpt-load = pkgs.callPackage ./gpt-load { };
  snow-ai = pkgs.callPackage ./snow-ai { };
}
