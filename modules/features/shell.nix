{ config, ... }:

let
  aliases = {
    ls = "eza -lah --icons";
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
        # Unreleased main: `---` separators and keypress passthrough fixes.
        (fetch.overrideAttrs (old: {
          version = "2.3.0-unstable-2026-09-21";
          src = fetchFromGitHub {
            owner = "areofyl";
            repo = "fetch";
            rev = "7b19d22c2d8e4b7b2295cc625c9fdf87adcabbcd";
            hash = "sha256-gCiEaSiMQND+auhMDCiSdLzj5CXvmYBltEAMRj73szc=";
          };
          meta = old.meta // {
            changelog = "https://github.com/areofyl/fetch/commits/main";
          };
        }))
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
    { pkgs, osConfig, ... }:
    let
      # The desktop's hostname differs from its flake attribute, the VM's matches.
      host = { ChrisNixOS = "desktop"; }.${osConfig.networking.hostName} or osConfig.networking.hostName;
      flake = "~/Projects/nixos";
      rebuild = action: "sudo nixos-rebuild ${action} --flake ${flake}#${host}";
    in
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

      # The same sections for fetch; it has no headings, `---` is a blank line.
      xdg.configFile."fetch/config".text = ''
        os
        kernel
        uptime
        packages
        ---
        shell
        wm
        theme
        font
        ---
        display
        cpu
        gpu
        memory
        disk
      '';

      programs.fish = {
        enable = true;

        shellAliases = aliases;

        # Abbreviations expand in place, so the full command is visible and lands in the history.
        shellAbbrs = {
          nrs = rebuild "switch";
          nrb = rebuild "boot";
          nrt = rebuild "test";
          nfu = "nix flake update --flake ${flake}";
          nfc = "nix flake check ${flake}";
          ngc = "sudo nix-collect-garbage --delete-older-than 7d";
          nup = "${flake}/scripts/update-packages --apply";
          nmc = "${flake}/scripts/update-mywm-chain --push";
          scu = "systemctl --user";
        };

        interactiveShellInit = ''
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
    };
  };
}
