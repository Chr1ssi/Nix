{
  description = "NixOS with mywm (River) and mywm-shell";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Application sources come from GitHub; configuration lives in this repository.
    mywm-src = { url = "github:Chr1ssi/mywm"; flake = false; };
    mywm-shell-src = { url = "github:Chr1ssi/mywm-shell"; flake = false; };
  };
  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      mywm = pkgs.callPackage ./packages/mywm.nix {
        src = inputs.mywm-src;
        shellSrc = inputs.mywm-shell-src;
      };
    in {
      packages.${system} = { inherit mywm; default = mywm; };
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit mywm; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.chris = import ./home.nix;
              backupFileExtension = "backup";
            };
          }
        ];
      };
    };
}
