{
  nixpkgs-unstable,
  ...
}: {
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (final) system config;
        };
      })
    ];
  };
}
