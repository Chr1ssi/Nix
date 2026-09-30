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
      config.flake.modules.nixos.user
      config.flake.modules.nixos.fish

      config.flake.modules.nixos.desktop
      config.flake.modules.nixos.greeter
      config.flake.modules.nixos.audio
      config.flake.modules.nixos.streamdeck
      config.flake.modules.nixos.mywm
      config.flake.modules.nixos.mywm-smithey

      config.flake.modules.nixos.browser
      config.flake.modules.nixos.apps
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

        home-manager.users.chris = {
          imports = [
            config.flake.modules.homeManager.theming
            config.flake.modules.homeManager.terminal
            config.flake.modules.homeManager.file-manager
            config.flake.modules.homeManager.firefox
            config.flake.modules.homeManager.starship
            config.flake.modules.homeManager.calendar
            config.flake.modules.homeManager.obsidian
          ];

          home.packages = [
            inputs.nixpkgs.legacyPackages.x86_64-linux.onlyoffice-desktopeditors
          ];
        };

        system.stateVersion = "26.05";
      }
    ];
  };
}
