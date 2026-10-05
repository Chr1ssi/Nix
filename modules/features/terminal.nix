{ ... }:

{
  # foot on Linux, kitty on macOS, where foot (Wayland-only) does not run.
  flake.modules.homeManager.terminal =
    { config, pkgs, ... }:
    {
      # Colors come from the theme mywm renders from the wallpaper.
      programs.foot = {
        enable = pkgs.stdenv.hostPlatform.isLinux;
        settings = {
          main = {
            font = "JetBrainsMono Nerd Font Mono:size=11";
            pad = "25x25";
            include = "${config.xdg.stateHome}/mywm/foot.ini";
          };
          colors-dark.alpha = 0.8;
        };
      };

      programs.kitty = {
        enable = pkgs.stdenv.hostPlatform.isDarwin;
        extraConfig =
          builtins.replaceStrings [ "include themes/noctalia.conf" ] [ "" ]
            (builtins.readFile ../../dotfiles/kitty/kitty.conf);
      };
    };
}
