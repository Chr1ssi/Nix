{ inputs, config, ... }:

{
  flake.nixosConfigurations.desktop =
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs;
      };

      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence

        config.flake.modules.nixos.base
        config.flake.modules.nixos.desktop-hardware
        config.flake.modules.nixos.desktop
        config.flake.modules.nixos.development
        config.flake.modules.nixos.gaming

        {
          networking.hostName = "desktop";

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";

            users.chris.imports = [
              config.flake.modules.homeManager.chris
              config.flake.modules.homeManager.essentials
              config.flake.modules.homeManager.development
              config.flake.modules.homeManager.mywm
            ];
          };

          system.stateVersion = "26.05";
        }
      ];
    };
}