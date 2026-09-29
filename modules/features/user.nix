{ config, ... }:

{
  flake.modules.nixos.user = {
    users.users.chris = {
      isNormalUser = true;

      extraGroups = [
        "wheel"
        "networkmanager"
      ];

      hashedPasswordFile = "/persist/passwords/chris";
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";

      users.chris.imports = [ config.flake.modules.homeManager.chris ];
    };
  };

  flake.modules.homeManager.chris = {
    home.username = "chris";
    home.homeDirectory = "/home/chris";
    home.stateVersion = "26.05";

    programs.home-manager.enable = true;
  };

  flake.modules.homeManager.mac-settings = {
    home.username = "chris";
    home.homeDirectory = "/Users/chris";
    home.stateVersion = "26.05";

    programs.home-manager.enable = true;

    targets.darwin.copyApps = {
      enable = true;
      directory = "Applications/Home Manager Apps";
    };
  };
}
