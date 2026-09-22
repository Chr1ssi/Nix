{ ... }:

{
  flake.modules.homeManager.niri =
    { pkgs, ... }:
    {
      xdg.configFile."niri/config.kdl".text = ''
        input {
          keyboard {
            xkb {
              layout "de"
            }
          }

          touchpad {
            tap
            natural-scroll
          }
        }

        layout {
          gaps 8

          center-focused-column "never"

          preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
          }

          default-column-width {
            proportion 0.5
          }

          focus-ring {
            width 2
          }
        }

        prefer-no-csd

        spawn-at-startup "${pkgs.dunst}/bin/dunst"

        hotkey-overlay {
          skip-at-startup
        }

        binds {
          Mod+Return {
            spawn "${pkgs.kitty}/bin/kitty";
          }

          Mod+Q {
            close-window;
          }

          Mod+H {
            focus-column-left;
          }

          Mod+L {
            focus-column-right;
          }

          Mod+J {
            focus-window-down;
          }

          Mod+K {
            focus-window-up;
          }

          Mod+Shift+H {
            move-column-left;
          }

          Mod+Shift+L {
            move-column-right;
          }

          Mod+Shift+J {
            move-window-down;
          }

          Mod+Shift+K {
            move-window-up;
          }

          Mod+1 {
            focus-workspace 1;
          }

          Mod+2 {
            focus-workspace 2;
          }

          Mod+3 {
            focus-workspace 3;
          }

          Mod+4 {
            focus-workspace 4;
          }

          Mod+5 {
            focus-workspace 5;
          }

          Mod+Shift+1 {
            move-column-to-workspace 1;
          }

          Mod+Shift+2 {
            move-column-to-workspace 2;
          }

          Mod+Shift+3 {
            move-column-to-workspace 3;
          }

          Mod+Shift+4 {
            move-column-to-workspace 4;
          }

          Mod+Shift+5 {
            move-column-to-workspace 5;
          }

          Mod+F {
            maximize-column;
          }

          Mod+Shift+F {
            fullscreen-window;
          }

          Mod+R {
            switch-preset-column-width;
          }

          Mod+Shift+E {
            quit;
          }
        }
      '';
    };
}