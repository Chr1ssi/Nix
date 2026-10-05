{ ... }:

{
  # kitty's theme include comes from mywm on Linux; macOS has no mywm.
  flake.modules.homeManager.terminal =
    { config, pkgs, ... }:
    {
      # foot is Wayland-only, so it is just for testing on Linux. mywm does not
      # render a foot theme yet, so it uses a static Catppuccin Mocha palette.
      programs.foot = {
        enable = pkgs.stdenv.hostPlatform.isLinux;
        settings = {
          main = {
            font = "JetBrainsMono Nerd Font Mono:size=11";
            pad = "25x25";
          };
          colors-dark = {
            alpha = 0.8;
            foreground = "cdd6f4";
            background = "1e1e2e";
            selection-foreground = "cdd6f4";
            selection-background = "414356";
            cursor = "11111b f5e0dc";
            regular0 = "45475a";
            regular1 = "f38ba8";
            regular2 = "a6e3a1";
            regular3 = "f9e2af";
            regular4 = "89b4fa";
            regular5 = "f5c2e7";
            regular6 = "94e2d5";
            regular7 = "bac2de";
            bright0 = "585b70";
            bright1 = "f38ba8";
            bright2 = "a6e3a1";
            bright3 = "f9e2af";
            bright4 = "89b4fa";
            bright5 = "f5c2e7";
            bright6 = "94e2d5";
            bright7 = "a6adc8";
          };
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
