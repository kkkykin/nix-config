{
  description = "NixOS configuration of kkky";
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nur--m.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nur--m.cachix.org-1:3B+L0JdIdbhI4u3eC5WTYDpIMiYDoe/BmvCQjMeSrBM="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-secrets = {
      url = "github:kkkykin/nixos-secrets-empty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kkkykin.url = "github:kkkykin/nur-packages/master";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-wsl,
    nixos-hardware,
    sops-nix,
    home-manager,
    nix-secrets,
    kkkykin,
    ...
  }: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # steal from https://github.com/Misterio77/nix-starter-configs/blob/main/standard/flake.nix
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;
    nixosConfigurations = {
      legion-wsl = let
        username = "nixos";
        specialArgs = inputs // {inherit outputs username;};
      in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "x86_64-linux";

          modules = [
            sops-nix.nixosModules.sops
            nixos-wsl.nixosModules.default
            ./modules/nixos/profiles/wsl.nix
            ./hosts/legion-wsl
            ./users/${username}/nixos.nix

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = inputs // specialArgs;
                users.${username} = {
                  imports = [
                    ./users/${username}/home.nix
                  ];
                  home.stateVersion = "25.05";
                };
              };
            }
          ];
        };
      asus = let
        username = "kkky";
        dotfileDir = "/home/${username}/dotfiles";
        specialArgs = inputs // {
          inherit outputs username dotfileDir;
          secrets = import nix-secrets;
        };
      in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "x86_64-linux";

          modules = [
            nixos-hardware.nixosModules.asus-battery
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-gpu-nvidia-disable
            nixos-hardware.nixosModules.common-pc-laptop-hdd
            nixos-hardware.nixosModules.common-pc-laptop-ssd
            {
              hardware = {
                asus.battery.chargeUpto = 60;
                intelgpu.vaapiDriver = "intel-media-driver";
              };
            }
            nix-secrets.nixosModules.asus
            {
              sops = {
                gnupg = {
                  home = "/root/.gnupg";
                  sshKeyPaths = [];
                };
              };
            }

            ./modules/nixos/profiles/server.nix
            ./hosts/asus
            ./users/${username}/nixos.nix

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = inputs // specialArgs;
                users.${username} = {
                  imports = [
                    ./users/${username}/home.nix
                  ];
                  home.stateVersion = "25.05";
                };
              };
            }
          ];
        };
    };
    devShells = {
      x86_64-linux.default = let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        sopsImportHook = (pkgs.callPackage sops-nix {}).sops-import-keys-hook;
      in pkgs.mkShell {
        name = "sops-gpg-import";

        nativeBuildInputs = [
          sopsImportHook
        ];

        sopsPGPKeyDirs = [
          "${self}/keys/hosts"
          "${self}/keys/users"
        ];

        # 可选：使用独立 GNUPGHOME，避免污染默认 keyring
        sopsCreateGPGHome = true;

        shellHook = ''
          export GPG_TTY=$(tty)
      gpgconf -R gpg-agent
      echo "🔐 sops-nix GPG import shell ready."
      echo "📁 Keys loaded from: keys/hosts and keys/users"
      echo "📦 GNUPGHOME: $GNUPGHOME"
        '';
      };
    };

  };
}
