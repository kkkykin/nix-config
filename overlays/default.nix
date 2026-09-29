{inputs, ...}: {
  modifications = final: prev: {
    sillytavern = final.unstable.sillytavern.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./patches/sillytavern/0001-openai-reverse-proxy-image-video.patch
        ];
    });

    ergochat = prev.ergochat.overrideAttrs (old: rec {
      version = "2.19.1";
      src = final.fetchFromGitHub {
        owner = "ergochat";
        repo = "ergo";
        rev = "v${version}";
        sha256 = "sha256-yzGLOpECalSOv1zBpVkyDlHGaHSsQNsAoNa2jgLpsgM=";
      };
      tags = (old.tags or []) ++ [ "sqlite" ];
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
