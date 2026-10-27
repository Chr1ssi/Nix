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

      programs.fastfetch = {
        enable = true;
        settings = {
          "$schema" = "https://raw.githubusercontent.com/fastfetch-cli/fastfetch/2.66.0/doc/json_schema.json";
          logo.type = "auto";
          display = {
            size = {
              maxPrefix = "MB";
              ndigits = 0;
              spaceBeforeUnit = "never";
            };
            freq = {
              ndigits = 3;
              spaceBeforeUnit = "never";
            };
          };
          modules = [
            "title"
            "separator"
            "os"
            "host"
            {
              type = "kernel";
              format = "{release}";
            }
            "uptime"
            {
              type = "packages";
              combined = true;
            }
            "separator"
            "wm"
            "icons"
            "shell"
            "terminal"
            {
              type = "terminalfont";
              format = "{/name}{-}{/}{name}{?size} {size}{?}";
            }
            "separator"
            "cpu"
            {
              type = "gpu";
              key = "GPU";
              format = "{name}";
            }
            {
              type = "memory";
              format = "{used} / {total}";
            }
            "break"
            "colors"
          ];
        };
      };

      # The same modules for fetch. It draws the title and its underline itself, `---` is only a
      # blank line, and `colors` brings its own blank line in front.
      xdg.configFile."fetch/config".text = ''
        os
        host
        kernel
        uptime
        packages
        ---
        wm
        icons
        shell
        terminal
        font
        ---
        cpu
        gpu
        memory
        colors
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
          nmc = "${flake}/scripts/update-splice-chain --push";
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
