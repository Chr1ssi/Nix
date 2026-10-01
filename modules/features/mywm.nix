{ config, inputs, ... }:

let
  monitors = config.monitors;
in
{
  flake.modules.nixos.mywm =
    { pkgs, ... }:
    let
      # Beendet einen haengengebliebenen Picker und bricht nach 45 s ab, damit
      # xdg-desktop-portal-wlr nicht ewig auf die Auswahl wartet und Anfragen blockiert.
      screencastChooser = pkgs.writeShellScriptBin "screencast-chooser" ''
        ${pkgs.procps}/bin/pkill -x fuzzel 2>/dev/null || true
        exec ${pkgs.coreutils}/bin/timeout 45 ${pkgs.fuzzel}/bin/fuzzel --dmenu --config=${pkgs.writeText "fuzzel-empty.ini" ""} \
          --prompt='  Teilen: ' \
          --font='JetBrainsMono Nerd Font:size=14' \
          --width=60 --lines=8 --line-height=32 \
          --inner-pad=16 --horizontal-pad=24 --vertical-pad=16 \
          --background-color=1e1e2ef2 --text-color=cdd6f4ff \
          --prompt-color=89b4faff --input-color=cdd6f4ff \
          --match-color=f5c2e7ff \
          --selection-color=313244ff --selection-text-color=cdd6f4ff \
          --selection-match-color=f5c2e7ff \
          --border-width=2 --border-radius=14 --border-color=89b4fa80
      '';
    in
    {
      imports = [ inputs.mywm.nixosModules.default ];

      home-manager.sharedModules = [ config.flake.modules.homeManager.mywm ];

      programs.mywm = {
        enable = true;
        greeterDirectory = "/persist/mywm-greeter";
      };

      xdg.portal = {
        config.river."org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];

        wlr.settings.screencast = {
          max_fps = 60;

          chooser_cmd = "${screencastChooser}/bin/screencast-chooser";
        };
      };
    };

  perSystem =
    { pkgs, ... }:
    let
      mywm = inputs.mywm.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      packages = {
        inherit mywm;
        default = mywm;
      };
    };

  flake.modules.homeManager.mywm =
    { config, pkgs, ... }:

    let
      toml = pkgs.formats.toml { };
      screenshot = pkgs.writeShellApplication {
        name = "mywm-screenshot";
        runtimeInputs = with pkgs; [
          grim
          libnotify
          slurp
          wl-clipboard
        ];
        text = ''
          screenshot_dir="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
          mkdir -p "$screenshot_dir"
          screenshot="$screenshot_dir/$(date +'%Y-%m-%d_%H-%M-%S').png"

          case "''${1:-full}" in
            full)
              grim "$screenshot"
              ;;
            region)
              selection=$(slurp) || exit 0
              grim -g "$selection" "$screenshot"
              ;;
            *)
              echo "Verwendung: mywm-screenshot [full|region]" >&2
              exit 2
              ;;
          esac

          wl-copy --type image/png < "$screenshot"
          notify-send "Screenshot gespeichert" "$screenshot"
        '';
      };
      xwaylandPrimary = pkgs.writeShellApplication {
        name = "xwayland-primary-output";
        runtimeInputs = [ pkgs.xrandr ];
        text = ''
          for _ in {1..50}; do
            if xrandr --query 2>/dev/null | grep -q '^${monitors.main} connected'; then
              exec xrandr --output ${monitors.main} --primary
            fi
            sleep 0.2
          done

          echo '${monitors.main} wurde von XWayland nicht rechtzeitig erkannt.' >&2
          exit 1
        '';
      };
      settings = {
        float_dialogs = true;
        # One fixed workspace per monitor, numbered in this order (main = 1, top = 2,
        # side = 3). Extra workspaces and the gaming workspace are created on demand.
        workspace_outputs = [
          monitors.main
          monitors.top
          monitors.side
        ];
        gaming_output = monitors.main;
        game_app_id_prefixes = [
          "steam_app_"
          "gamescope"
        ];
        async_outputs = [ monitors.main ];

        terminal = [
          "${pkgs.kitty}/bin/kitty"
        ];

        program_bindings = {
          browser = {
            keys = [ "Super+b" ];
            command = [ "${pkgs.local.helium}/bin/helium" ];
          };

          file_manager = {
            keys = [ "Super+f" ];
            command = [ "${pkgs.nemo}/bin/nemo" ];
          };

          zed_editor = {
            keys = [ "Super+e" ];
            command = [ "${pkgs.zed-editor}/bin/zeditor" ];
          };

          claude = {
            keys = [ "Super+c" ];
            command = [ "${pkgs.local.claude-desktop}/bin/claude-desktop" ];
          };

          screenshot_full = {
            keys = [ "Super+Ctrl+Shift+p" ];
            command = [
              "${screenshot}/bin/mywm-screenshot"
              "full"
            ];
          };

          screenshot_region = {
            keys = [ "Super+Shift+p" ];
            command = [
              "${screenshot}/bin/mywm-screenshot"
              "region"
            ];
          };
        };

        wallpaper_directory = "${config.home.homeDirectory}/Pictures/Wallpapers";

        keyboard = {
          layout = "de";
          variant = "";
          options = "";
        };

        idle = {
          lock_after_seconds = 600;
          monitor_off_after_seconds = 6000;
        };

        bindings = {
          reload = [ "Super+Shift+r" ];
          wallpaper = [ "Super+Shift+w" ];
          lock = [ "Super+Escape" ];
          terminal = [ "Super+Return" ];
          launcher = [ "Super+Space" ];
          close = [ "Super+q" ];
          exit = [ "Super+m" ];
          toggle_floating = [ "Super+v" ];
          toggle_scratchpad = [ "Super+s" ];
          move_to_scratchpad = [ "Super+Shift+s" ];

          focus_output_left = [ "Super+Alt+Left" ];
          focus_output_right = [ "Super+Alt+Right" ];
          focus_output_up = [ "Super+Alt+Up" ];
          focus_output_down = [ "Super+Alt+Down" ];
          move_to_output_left = [ "Super+Shift+Left" ];
          move_to_output_right = [ "Super+Shift+Right" ];
          move_to_output_up = [ "Super+Shift+Up" ];
          move_to_output_down = [ "Super+Shift+Down" ];

          pointer_modifiers = "Super";

          focus_left = [
            "Super+h"
            "Super+Left"
          ];
          focus_right = [
            "Super+l"
            "Super+Right"
          ];
          move_left = [ "Super+Shift+h" ];
          move_right = [ "Super+Shift+l" ];

          workspace_previous = [
            "Super+Ctrl+Left"
            "Super+Ctrl+Up"
          ];
          workspace_next = [
            "Super+Ctrl+Right"
            "Super+Ctrl+Down"
          ];
          move_to_workspace_previous = [ "Super+Ctrl+Shift+Up" ];
          move_to_workspace_next = [ "Super+Ctrl+Shift+Down" ];

          workspace_modifiers = "Super";
          move_to_workspace_modifiers = "Super+Shift";
        };

        appearance = {
          gaps_inner = 4;
          gaps_outer = 4;
          border_width = 2;

        };

        rules = [
          {
            dialog = true;
            floating = true;
          }
        ];
      };
    in
    {
      xdg.configFile."mywm/config.toml".source = toml.generate "mywm.toml" settings;

      # Smithay session config: a plain file in the repo, linked out of the store so the
      # settings editor can write it and the compositor reloads it live.
      xdg.configFile."mywm/smithay.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects/nixos/dotfiles/mywm/smithay.toml";

      home.packages = [
        screenshot
      ];

      systemd.user.services = {
        xwayland-primary-output = {
          Unit = {
            Description = "Mark the main output as the primary XWayland output";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${xwaylandPrimary}/bin/xwayland-primary-output";
            RemainAfterExit = true;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };

      xdg.configFile."kanshi/config".text = ''
        profile desktop {
          output ${monitors.top} enable mode 2560x1080@60Hz position 0,0 scale 1 transform normal
          output ${monitors.main} enable mode 2560x1440@143.97Hz position 0,1080 scale 1 transform normal adaptive_sync off
          output ${monitors.side} enable mode 2560x1440@59.95Hz position 2560,0 scale 1 transform 270
        }
      '';

      home.file."Pictures/Wallpapers" = {
        source = ../../wallpapers;
        recursive = true;
      };
    };
}
