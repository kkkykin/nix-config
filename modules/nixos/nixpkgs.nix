{
  outputs,
  ...
}: {
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
  };
}
