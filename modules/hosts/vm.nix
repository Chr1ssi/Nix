{ inputs, config, ... }:

{
  flake.nixosConfigurations.vm =
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
        config.flake.modules.nixos.vm-hardware
        config.flake.modules.nixos.vm-disko

        config.flake.modules.nixos.impermanence

        config.flake.modules.nixos.desktop
        config.flake.modules.nixos.mywm
        config.flake.modules.nixos.development

        {
          networking.hostName = "vm";

          boot.loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";

            users.chris.imports = [
              config.flake.modules.homeManager.chris
              config.flake.modules.homeManager.essentials
              config.flake.modules.homeManager.shell
              config.flake.modules.homeManager.development
              config.flake.modules.homeManager.firefox

              config.flake.modules.homeManager.mywm
            ];
          };

          system.stateVersion = "26.05";
        }
      ];
    };
}
