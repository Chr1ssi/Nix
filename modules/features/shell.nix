{ config, ... }:

let
  aliases = {
    ls = "eza";
    ll = "eza -la";
    la = "eza -a";
    cat = "bat";
  };

  # Shared by fish and zsh; Home Manager hooks zoxide and fzf into every enabled shell.
  common =
    { pkgs, ... }:
    {
      programs.zoxide.enable = true;
      programs.fzf.enable = true;
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
      imports = [ common ];

      programs.fish = {
        enable = true;

        shellAliases = aliases;

        interactiveShellInit = ''
          fastfetch -c screenfetch.jsonc
          type -q enable_transience; and enable_transience
        '';
      };

      home.packages = with pkgs; [
        pciutils
        usbutils
      ];
    };

  flake.modules.homeManager.zsh = {
    imports = [ common ];

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
  };
}
