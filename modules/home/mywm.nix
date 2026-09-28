{ ... }:

{
  flake.modules.homeManager.mywm =
    { config, pkgs, ... }:

    let
      chatgpt = pkgs.callPackage ../../packages/chatgpt-linux.nix { };
      helium = pkgs.callPackage ../../packages/helium.nix { };
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
            if xrandr --query 2>/dev/null | grep -q '^DP-3 connected'; then
              exec xrandr --output DP-3 --primary
            fi
            sleep 0.2
          done

          echo 'DP-3 wurde von XWayland nicht rechtzeitig erkannt.' >&2
          exit 1
        '';
      };
    in
    {
      xdg.configFile."mywm/config.toml".source = toml.generate "mywm.toml" {
        workspaces = 4;
        float_dialogs = true;
        gaming_workspace = 2;
        game_app_id_prefixes = [
          "steam_app_"
          "gamescope"
        ];
        async_outputs = [ "DP-3" ];

        vrr = {
          enabled = true;
          output = "DP-3";
          command = [ "${pkgs.wlr-randr}/bin/wlr-randr" ];
        };

        workspace_outputs = {
          "DP-3" = [
            1
            2
          ];
          "HDMI-A-1" = [ 3 ];
          "DP-1" = [ 4 ];
        };

        terminal = [
          "${pkgs.kitty}/bin/kitty"
        ];

        program_bindings = {
          browser = {
            keys = [ "Super+b" ];
            command = [ "${helium}/bin/helium" ];
          };

          file_manager = {
            keys = [ "Super+f" ];
            command = [ "${pkgs.nemo}/bin/nemo" ];
          };

          zed_editor = {
            keys = [ "Super+e" ];
            command = [ "${pkgs.zed-editor}/bin/zeditor" ];
          };

          chatgpt = {
            keys = [ "Super+c" ];
            command = [ "${chatgpt}/bin/chatgpt" ];
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

      home.packages = [
        screenshot
      ];

      systemd.user.targets.mywm-session.Unit = {
        Description = "mywm compositor session";
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
        Before = [ "graphical-session.target" ];
      };

      systemd.user.services = {
        easyeffects = {
          Unit = {
            Description = "Easy Effects audio processing";
            PartOf = [ "graphical-session.target" ];
            After = [
              "graphical-session.target"
              "pipewire.service"
            ];
          };
          Service = {
            ExecStart = "${pkgs.easyeffects}/bin/easyeffects --service-mode --hide-window";
            ExecStartPost = "${pkgs.easyeffects}/bin/easyeffects --load-preset 'Wave3 Clean'";
            Restart = "on-failure";
            RestartSec = 2;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };

        xwayland-primary-output = {
          Unit = {
            Description = "Mark DP-3 as the primary XWayland output";
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
          output HDMI-A-1 enable mode 2560x1080@60Hz position 0,0 scale 1 transform normal
          output DP-3 enable mode 2560x1440@143.97Hz position 0,1080 scale 1 transform normal adaptive_sync off
          output DP-1 enable mode 2560x1440@59.95Hz position 2560,0 scale 1 transform 270
        }
      '';

      home.file."Pictures/Wallpapers" = {
        source = ../../wallpapers;
        recursive = true;
      };
    };
}
