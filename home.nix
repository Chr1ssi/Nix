{ pkgs, ... }:

{
  home.username = "chris";
  home.homeDirectory = "/home/chris";

  home.stateVersion = "26.05";

  programs.git.enable = true;

  home.packages = with pkgs; [
    waybar
    rofi
    dunst
  ];
  
  # Hyprland
  xdg.configFile."hypr/hyprland.lua".source = ./hypr/hyprland.lua;
  xdg.configFile."hypr/monitors.lua".source = ./hypr/monitors.lua;
  xdg.configFile."hypr/programs.lua".source = ./hypr/programs.lua;
  xdg.configFile."hypr/environment.lua".source = ./hypr/environment.lua;
  xdg.configFile."hypr/appearance.lua".source = ./hypr/appearance.lua;
  xdg.configFile."hypr/input.lua".source = ./hypr/input.lua;
  xdg.configFile."hypr/keybinds.lua".source = ./hypr/keybinds.lua;
  xdg.configFile."hypr/rules.lua".source = ./hypr/rules.lua;

  # Waybar
  xdg.configFile."waybar/config".source = ./waybar/config;
  xdg.configFile."waybar/style.css".source = ./waybar/style.css;


}
