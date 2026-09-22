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
        config.flake.modules.nixos.desktop
        config.flake.modules.nixos.development

        # IMPORTANT:
        # vm-disko is NOT imported yet because the currently
        # installed VM still uses its existing filesystem layout.
        #
        # Add this for the fresh Disko installation:
        #
        # config.flake.modules.nixos.vm-disko

        {
          networking.hostName = "vm";

          boot.loader.grub = {
            enable = true;
            device = "/dev/vda";
            useOSProber = true;
          };

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
