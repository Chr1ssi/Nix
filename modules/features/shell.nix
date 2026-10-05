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

      # The modules of fastfetch's screenfetch preset, grouped into sections.
      programs.fastfetch = {
        enable = true;
        settings =
          let
            section = name: {
              type = "custom";
              format = "── ${name} ──";
              outputColor = "bold_keys";
            };
          in
          {
            display = {
              separator = " ";
              key = {
                width = 15;
                paddingLeft = 2;
              };
            };
            modules = [
              "title"
              (section "System")
              "os"
              "kernel"
              "uptime"
              {
                type = "packages";
                format = "{all}";
              }
              "break"
              (section "Software")
              "shell"
              {
                type = "de";
                key = "DE";
              }
              {
                type = "wm";
                key = "WM";
              }
              "wmtheme"
              {
                type = "terminalfont";
                key = "Font";
              }
              "break"
              (section "Hardware")
              {
                type = "display";
                key = "Resolution";
                compactType = "original";
              }
              "cpu"
              "gpu"
              {
                type = "memory";
                key = "RAM";
              }
              {
                type = "disk";
                key = "Disk";
                folders = "/";
              }
            ];
          };
      };

      programs.fish = {
        enable = true;

        shellAliases = aliases;

        interactiveShellInit = ''
          fastfetch
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
