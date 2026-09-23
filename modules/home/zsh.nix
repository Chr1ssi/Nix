{ ... }:

{
  flake.modules.homeManager.zsh =
    { pkgs, ... }:
    {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion = {
          enable = true;
          strategy = [ "history" ];
        };
        syntaxHighlighting = {
          enable = true;
        };

        shellAliases = {
          ls = "eza";
          ll = "eza -la";
          la = "eza -a";
          cat = "bat";
        };

        initContent = ''
          fastfetch
        '';
      };

      programs.starship = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.bat.enable = true;

      home.packages = with pkgs; [
        fastfetch
        eza
        btop
        tree
        file
        which
      ];
    };
}
