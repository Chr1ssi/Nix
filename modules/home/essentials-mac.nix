{ ... }:

{
  flake.modules.homeManager.essentials-mac =
    { pkgs, ... }:
    {
      programs.git.enable = true;

      programs.kitty = {
        enable = true;
        extraConfig = builtins.replaceStrings
          [ "include themes/noctalia.conf" ]
          [ "" ]
          (builtins.readFile ../../dotfiles/kitty/kitty.conf);
      };

      home.packages = with pkgs; [
        kitty
        chatgpt
      ];
    };
}
