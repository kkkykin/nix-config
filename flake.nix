{
  description = "NixOS configuration of kkky";
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-wsl,
    nixos-hardware,
    sops-nix,
    home-manager,
    ...
  }: {
    nixosConfigurations = {
      legion-wsl = let
        username = "nixos";
        specialArgs = inputs // {inherit username;};
      in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "x86_64-linux";

          modules = [
            sops-nix.nixosModules.sops
            nixos-wsl.nixosModules.default
            ./hosts/legion-wsl
            ./users/${username}/nixos.nix

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = inputs // specialArgs;
                users.${username} = import ./users/${username}/home.nix;
              };
            }
          ];
        };
      asus = let
        username = "kkky";
        dotfileDir = "/home/${username}/dotfiles";
        specialArgs = inputs // {inherit username dotfileDir;};
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
              };
            }
            sops-nix.nixosModules.sops
            {
              sops = {
                gnupg = {
                  home = "/root/.gnupg";
                  sshKeyPaths = [];
                };
              };
            }

            ./hosts/asus
            ./users/${username}/nixos.nix

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = inputs // specialArgs;
                users.${username} = import ./users/${username}/home.nix;
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
