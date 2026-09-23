{ ... }:

{
  flake.modules.homeManager.essentials-mac =
    { pkgs, ... }:
    {
      programs.git.enable = true;

      programs.kitty = {
        enable = true;
        extraConfig =
          builtins.readFile ../../dotfiles/kitty/kitty.conf;
      };

      xdg.configFile."kitty/themes/noctalia.conf".source =
        ../../dotfiles/kitty/themes/noctalia.conf;

      home.packages = with pkgs; [
        kitty
        chatgpt
      ];
    };
}
