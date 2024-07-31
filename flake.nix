{
  description = "Gen's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.90.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, lix-module, ... }@inputs:
    {
      nixosConfigurations = {
        "XDE60" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./configuration.nix

            # add lix
            lix-module.nixosModules.default

            {
              _module.args = {
                inherit inputs;
              };
            }
            {
              nixpkgs = {
                hostPlatform = "x86_64-linux"; # set the system type
                config.allowUnfree = true;
              };
            }

            # home manager
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                extraSpecialArgs = {
                  inherit inputs;
                };
                users."gen".imports = [ ./home.nix ];
              };
            }
          ];
        };
      };
    };
}