{ config, lib, ... }:

let
  aliases = {
    ls = "eza";
    ll = "eza -la";
    la = "eza -a";
    cat = "bat";
  };

  # Play once instead of looping until a key is pressed. Key restore types the
  # pressed key back via pynput, which does not reach Wayland terminals.
  # `-c anifetch` loads ~/.config/fastfetch/anifetch.jsonc (see anifetchConfig).
  anifetchArgs = "example.mp4 --loop 1 --no-input-restore -c anifetch";

  # fastfetch's shell module reports its parent process, which under anifetch
  # is anifetch itself, so the shell line runs the shell for its version.
  anifetchConfig = settings: shellCommand: {
    xdg.configFile."fastfetch/anifetch.jsonc".text = builtins.toJSON (
      settings
      // {
        modules = map (
          module:
          let
            attrs = if builtins.isString module then { type = module; } else module;
          in
          if attrs.type == "shell" then
            {
              key = "Shell";
            }
            // attrs
            // {
              type = "command";
              text = shellCommand;
            }
          else
            module
        ) settings.modules;
      }
    );
  };

  # A section heading in the key color.
  section = name: {
    type = "custom";
    format = "── ${name} ──";
    outputColor = "bold_keys";
  };

  # A module with its key padded to a fixed width. fastfetch's own key width
  # jumps to an absolute column, which lands inside anifetch's animation.
  entry =
    key: module:
    (if builtins.isString module then { type = module; } else module)
    // {
      key = key + lib.strings.replicate (11 - builtins.stringLength key) " ";
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
        local.anifetch
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
      imports = [
        common
        # The modules of fastfetch's screenfetch preset, grouped into sections.
        (anifetchConfig {
          display = {
            separator = " ";
            key.paddingLeft = 2;
          };
          modules = [
            "title"
            (section "System")
            (entry "OS" "os")
            (entry "Kernel" "kernel")
            (entry "Uptime" "uptime")
            (entry "Packages" {
              type = "packages";
              format = "{all}";
            })
            "break"
            (section "Software")
            (entry "Shell" "shell")
            (entry "DE" "de")
            (entry "WM" "wm")
            (entry "WM Theme" "wmtheme")
            (entry "Font" "terminalfont")
            "break"
            (section "Hardware")
            (entry "Resolution" {
              type = "display";
              compactType = "original";
            })
            (entry "CPU" "cpu")
            (entry "GPU" "gpu")
            (entry "RAM" "memory")
            (entry "Disk" {
              type = "disk";
              folders = "/";
            })
          ];
        } "fish --no-config -c 'echo fish $version'")
      ];

      programs.fish = {
        enable = true;

        shellAliases = aliases;

        interactiveShellInit = ''
          anifetch ${anifetchArgs}
          type -q enable_transience; and enable_transience
        '';
      };

      home.packages = with pkgs; [
        pciutils
        usbutils
      ];
    };

  flake.modules.homeManager.zsh = {
    imports = [
      common
      # fastfetch's default modules.
      (anifetchConfig {
        modules = [
          "title"
          "separator"
          "os"
          "host"
          "kernel"
          "uptime"
          "packages"
          "shell"
          "display"
          "de"
          "wm"
          "wmtheme"
          "theme"
          "icons"
          "font"
          "cursor"
          "terminal"
          "terminalfont"
          "cpu"
          "gpu"
          "memory"
          "swap"
          "disk"
          "localip"
          "battery"
          "poweradapter"
          "locale"
          "break"
          "colors"
        ];
      } "zsh -fc 'echo zsh $ZSH_VERSION'")
    ];

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
        anifetch ${anifetchArgs}
      '';
    };
  };
}
