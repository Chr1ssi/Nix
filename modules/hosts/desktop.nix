{ inputs, config, ... }:

{
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
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

      config.flake.modules.nixos.development
      config.flake.modules.nixos.gaming

      {

        boot.loader = {
          limine = {
            enable = true;
            maxGenerations = 10;
            extraEntries = ''
              /Windows
              protocol: efi
              path: guid(39005b6f-42fb-4d02-b04b-d9c08f7aacb3):/EFI/Microsoft/Boot/bootmgfw.efi
            '';
          };

          efi.canTouchEfiVariables = true;
        };

        networking.hostName = "ChrisNixOS";

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";

          users.chris = {
            imports = [
              config.flake.modules.homeManager.chris
              config.flake.modules.homeManager.essentials
              config.flake.modules.homeManager.firefox
              config.flake.modules.homeManager.fish
              config.flake.modules.homeManager.starship
              config.flake.modules.homeManager.development
              config.flake.modules.homeManager.calendar
              config.flake.modules.homeManager.obsidian

              config.flake.modules.homeManager.mywm
            ];

            home.packages = [
              inputs.nixpkgs.legacyPackages.x86_64-linux.onlyoffice-desktopeditors
            ];
          };
        };

        system.stateVersion = "26.05";
      }
    ];
  };
}
