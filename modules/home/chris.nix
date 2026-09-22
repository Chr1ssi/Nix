{ ... }:

{
  flake.modules.homeManager.chris = {
    home.username = "chris";
    home.homeDirectory = "/home/chris";
    home.stateVersion = "26.05";

    programs.home-manager.enable = true;
  };
}
