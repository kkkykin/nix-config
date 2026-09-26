{
  description = "NixOS configuration of kkky";
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nur--m.cachix.org"
      "https://attic.xuyh0120.win/lantian"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nur--m.cachix.org-1:3B+L0JdIdbhI4u3eC5WTYDpIMiYDoe/BmvCQjMeSrBM="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent.url = "github:NousResearch/hermes-agent";
    # 真实仓库通过 Makefile 的 --override-input 指向 ../nix-secrets
    nix-secrets = {
      url = "github:kkkykin/nixos-secrets-empty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 自定义包与服务模块，本地开发时由 Makefile 指向 ../nur-packages
    kkkykin.url = "github:kkkykin/nur-packages/master";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nix-secrets,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux"];

    # hostname:   hosts/<hostname> 目录名
    # secretsKey: nix-secrets 中的键名，null 表示不使用 secrets
    mkHost = {
      hostname,
      username,
      secretsKey ? null,
      system ? "x86_64-linux",
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs username;
          secrets =
            if secretsKey != null
            then (import nix-secrets).${secretsKey}
            else {};
        };
        modules =
          [
            ./modules/common/base.nix
            ./hosts/${hostname}
          ]
          ++ nixpkgs.lib.optional (secretsKey != null) nix-secrets.nixosModules.${secretsKey};
      };
  in {
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    overlays = import ./overlays {inherit inputs;};

    nixosConfigurations = {
      asus = mkHost {
        hostname = "asus";
        secretsKey = "asus";
        username = "kkky";
      };
      cone-vps = mkHost {
        hostname = "cone-vps";
        secretsKey = "cone";
        username = "cone";
      };
      dmit-vps = mkHost {
        hostname = "dmit-vps";
        secretsKey = "dmit";
        username = "dmit";
      };
      legion-wsl = mkHost {
        hostname = "legion-wsl";
        username = "nixos";
      };
    };
  };
}
