{
  nixpkgs-unstable,
  ...
}: {
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (final: prev: let
        unstable = import nixpkgs-unstable {
          inherit (final) system config;
        };
      in {
        unstable = unstable;
        
        komga = unstable.komga;
      })
    ];
  };
}
