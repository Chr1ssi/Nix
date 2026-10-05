{ ... }:

{
  # kitty's theme include comes from mywm on Linux; macOS has no mywm.
  flake.modules.homeManager.terminal =
    { config, pkgs, ... }:
    {
      # foot is Wayland-only, so it is just for testing on Linux. Its colors
      # come from the theme mywm renders from the wallpaper.
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
        enable = true;
        extraConfig =
          builtins.replaceStrings
            [ "include themes/noctalia.conf" ]
            [
              (
                if pkgs.stdenv.hostPlatform.isDarwin then "" else "include ${config.xdg.stateHome}/mywm/kitty.conf"
              )
            ]
            (builtins.readFile ../../dotfiles/kitty/kitty.conf);
      };
    };
}
