{ config, ... }:

let
  aliases = {
    ls = "eza";
    ll = "eza -la";
    la = "eza -a";
    cat = "bat";
  };
in
{
  # NixOS hosts use fish, the Mac uses zsh (see hosts/mac.nix).
  flake.modules.nixos.fish =
    { pkgs, ... }:
    {
      programs.fish.enable = true;
      users.users.chris.shell = pkgs.fish;

      home-manager.sharedModules = [ config.flake.modules.homeManager.fish ];
    };

  flake.modules.homeManager.fish =
    { pkgs, ... }:
    {
      programs.fish = {
        enable = true;

        shellAliases = aliases;

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
        syntaxHighlighting.enable = true;

        shellAliases = aliases;

        initContent = ''
          fastfetch
        '';
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
