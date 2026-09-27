{ ... }:

{
  flake.modules.homeManager.fish =
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
          type -q enable_transience; and enable_transience
        '';
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
