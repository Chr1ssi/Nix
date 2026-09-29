{ config, ... }:

{
  flake.modules.nixos.apps.home-manager.sharedModules = [ config.flake.modules.homeManager.apps ];

  flake.modules.homeManager.apps =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        mpv
        imv
        local.claude-desktop
        local.chatgpt-linux
      ];
    };
}
