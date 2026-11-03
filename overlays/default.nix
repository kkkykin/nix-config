{inputs, ...}: {
  modifications = final: prev: {
    sillytavern = final.unstable.sillytavern.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./patches/sillytavern/0001-openai-reverse-proxy-image-video.patch
        ];
    });

    ergochat = final.unstable.ergochat;

    emacs-git-nox = inputs.emacs-overlay.packages.${final.stdenv.hostPlatform.system}.emacs-git-nox;
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
