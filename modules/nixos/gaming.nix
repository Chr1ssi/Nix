{ config, lib, pkgs, ... }:
{
  options.profiles.gaming.enable = lib.mkEnableOption "Steam, Heroic and Vesktop";
  config = lib.mkIf config.profiles.gaming.enable {
    nixpkgs.config.allowUnfree = true;
    programs.steam.enable = true;
    hardware.graphics.enable32Bit = true;
    services.pipewire.alsa.support32Bit = true;
    home-manager.users.chris.home.packages = with pkgs; [ heroic vesktop ];
    home-manager.users.chris.xdg.configFile."vesktop/settings.json".source = ../../dotfiles/vesktop/settings.json;
  };
}
