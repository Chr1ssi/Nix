{ inputs, config, ... }:

{
  flake.darwinConfigurations.mac =
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";

      specialArgs = {
        inherit inputs;
      };

      modules = [
        inputs.home-manager.darwinModules.home-manager

        {
          networking.hostName = "air";

          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];

          nixpkgs.config.allowUnfree = true;

          users.users.chris.home = "/Users/chris";
          users.users.chris.shell = "/bin/zsh";

          homebrew = {
            enable = true;

            onActivation = {
              autoUpdate = true;
              upgrade = true;
              cleanup = "zap";
            };

            casks = [
              "the-unarchiver"
              "font-jetbrains-mono-nerd-font"
              "homebrew-app"

              {
                name = "darrylmorley/whatcable/whatcable";
                trusted = true;
              }
            ];

            brews = [
              "mole"
            ];

            masApps = {
              "LocalSend" = 1661733229;
              "UBlock OriginLite" = 6745342698;
              "Noir" = 1592917505;
              "Wireguard" = 1451685025;
              "XCode" = 497799835;
              "Numbers" = 361304891;
              "Pages" = 361309726;
              "Keynote" = 361285480;
            };
          };

          system.defaults = {
            finder.FXPreferredViewStyle = "clmv";

            loginwindow.GuestEnabled = false;

            NSGlobalDomain = {
              AppleICUForce24HourTime = true;
              AppleInterfaceStyle = "Dark";

              KeyRepeat = 4;
              InitialKeyRepeat = 25;
            };
          };

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "before-nix";

            users.chris = {
              imports = [
                config.flake.modules.homeManager.mac-settings
                config.flake.modules.homeManager.essentials-mac
                config.flake.modules.homeManager.zsh
                config.flake.modules.homeManager.development
              ];
            };
          };

          system.primaryUser = "chris";
          system.stateVersion = 6;

        }
      ];
    };
}
