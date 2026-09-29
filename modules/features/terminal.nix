{ ... }:

{
  # kitty's theme include comes from mywm on Linux; macOS has no mywm.
  flake.modules.homeManager.terminal =
    { config, pkgs, ... }:
    {
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
