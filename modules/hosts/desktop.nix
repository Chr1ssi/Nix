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
        inputs.impermanence.nixosModules.impermanence

        config.flake.modules.nixos.base
        config.flake.modules.nixos.desktop-hardware
        config.flake.modules.nixos.desktop-storage
        config.flake.modules.nixos.impermanence

        config.flake.modules.nixos.desktop
        config.flake.modules.nixos.mywm
        config.flake.modules.nixos.niri

        config.flake.modules.nixos.development
        config.flake.modules.nixos.gaming

        {

          boot.loader = {
            limine = {
              enable = true;
              maxGenerations = 10;
            };

            efi.canTouchEfiVariables = true;
          };

          networking.hostName = "ChrisNixOS";

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";

            users.chris.imports = [
              config.flake.modules.homeManager.chris
              config.flake.modules.homeManager.essentials
              config.flake.modules.homeManager.firefox
              config.flake.modules.homeManager.fish
              config.flake.modules.homeManager.development

              config.flake.modules.homeManager.mywm
              config.flake.modules.homeManager.niri
            ];
          };

          system.stateVersion = "26.05";
        }
      ];
    };
}
