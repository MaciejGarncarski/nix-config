{
  description = "System Config Flake";

  inputs = {
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-flatpak,
      home-manager,
      ...
    }@inputs:
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;

      nixosConfigurations = {
        nix-os = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            username = "maciek";
            inputs = inputs;
          };
          modules = [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
            }
            ./home-manager/home.nix
            ./hosts/nix-os/configuration.nix
            nix-flatpak.nixosModules.nix-flatpak
            { nixpkgs.config.allowUnfree = true; }
          ];
        };

        vm-nix-os = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            username = "maciek";
            inputs = inputs;
          };
          modules = [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
            }
            ./home-manager/home.nix
            ./hosts/vm-nix-os/configuration.nix
            nix-flatpak.nixosModules.nix-flatpak
            { nixpkgs.config.allowUnfree = true; }
          ];
        };

        nix-server = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            username = "maciek";
            inputs = inputs;
          };
          modules = [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
            }
            ./home-manager/home.nix
            ./hosts/nix-server/configuration.nix
            nix-flatpak.nixosModules.nix-flatpak
            { nixpkgs.config.allowUnfree = true; }
          ];
        };
      };
    };
}
