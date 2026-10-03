{ config, ... }:

{
  flake.modules.nixos.apps = {
    # Also opens LocalSend's port (53317) in the firewall.
    programs.localsend.enable = true;

    home-manager.sharedModules = [ config.flake.modules.homeManager.apps ];
  };

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
