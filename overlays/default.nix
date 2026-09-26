{inputs, ...}: {
  modifications = final: prev: {
    sillytavern = final.unstable.sillytavern.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./patches/sillytavern/0001-openai-reverse-proxy-image-video.patch
        ];
    });
  };

  # pkgs.unstable.* 与 pkgs.kkkykin.*（../nur-packages）
  extra-package-sets = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
    kkkykin = import inputs.kkkykin {pkgs = final;};
  };
}
