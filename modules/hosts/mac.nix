{ inputs, ... }:

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

          users.users.chris.home = "/Users/chris";

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            users.chris = {
              home.username = "chris";
              home.homeDirectory = "/Users/chris";

              home.stateVersion = "26.05";

              programs.git.enable = true;
              programs.home-manager.enable = true;
            };
          };

          system.primaryUser = "chris";

          system.stateVersion = 6;
        }
      ];
    };
}