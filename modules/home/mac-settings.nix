{ config, pkgs, ... }:

{
  flake.modules.homeManager.mac-settings = {
    home.username = "chris";
    home.homeDirectory = "/Users/chris";
    home.stateVersion = "26.05";

    programs.home-manager.enable = true;

    # Symlink home-manager Apps nach /Applications für Spotlight
    home.activation.symlinkApps = ''
      run mkdir -p /Applications
      run find /Users/chris/Applications -maxdepth 1 -name "*.app" -exec ln -sf {} /Applications/ \;
    '';
  };
}
