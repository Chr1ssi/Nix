{ ... }:

{
  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      programs.fish = {
        enable = true;

        shellAliases = {
          ls = "eza";
          ll = "eza -la";
          la = "eza -a";
          cat = "bat";
        };

        interactiveShellInit = ''
          fastfetch
        '';
      };

      programs.starship = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.bat.enable = true;

      home.packages = with pkgs; [
        fastfetch
        eza
        btop
        tree
        file
        which
        pciutils
        usbutils
      ];
    };
}
