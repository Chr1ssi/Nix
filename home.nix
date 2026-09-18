{ ... }:
{
  imports = [ ./modules/home/essentials.nix ./modules/home/mywm.nix ];
  home.username = "chris";
  home.homeDirectory = "/home/chris";
  home.stateVersion = "26.05";
}
