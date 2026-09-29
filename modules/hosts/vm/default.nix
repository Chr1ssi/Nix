{ inputs, config, ... }:

{
  flake.nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
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
      config.flake.modules.nixos.user
      config.flake.modules.nixos.fish

      config.flake.modules.nixos.desktop
      config.flake.modules.nixos.greeter
      config.flake.modules.nixos.audio
      config.flake.modules.nixos.streamdeck
      config.flake.modules.nixos.mywm

      config.flake.modules.nixos.browser
      config.flake.modules.nixos.apps
      config.flake.modules.nixos.development

      {
        networking.hostName = "vm";

        boot.loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };

        home-manager.users.chris.imports = [
          config.flake.modules.homeManager.theming
          config.flake.modules.homeManager.terminal
          config.flake.modules.homeManager.file-manager
          config.flake.modules.homeManager.firefox
        ];

        system.stateVersion = "26.05";
      }
    ];
  };
}
