{ ... }:

{
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
