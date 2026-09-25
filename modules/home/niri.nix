{ inputs, ... }:

{
  flake.modules.homeManager.niri =
    { config, pkgs, ... }:

    let
      chatgpt = pkgs.callPackage ../../packages/chatgpt-linux.nix { };
      helium = pkgs.callPackage ../../packages/helium.nix { };
      shell = inputs.mywm-shell.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      home.packages = [ shell ];

      xdg.configFile."niri/config.kdl".text = ''
        output "HDMI-A-1" {
          mode "2560x1080@60"
          scale 1
          transform "normal"
          position x=0 y=0
        }

        output "DP-3" {
          mode "2560x1440@143.97"
          scale 1
          transform "normal"
          position x=0 y=1080
        }

        output "DP-1" {
          mode "2560x1440@59.95"
          scale 1
          transform "270"
          position x=2560 y=0
        }

        workspace "1" { open-on-output "DP-3"; }
        workspace "2" { open-on-output "DP-3"; }
        workspace "3" { open-on-output "DP-3"; }
        workspace "4" { open-on-output "HDMI-A-1"; }
        workspace "5" { open-on-output "HDMI-A-1"; }
        workspace "6" { open-on-output "HDMI-A-1"; }
        workspace "7" { open-on-output "DP-1"; }
        workspace "8" { open-on-output "DP-1"; }
        workspace "9" { open-on-output "DP-1"; }

        environment {
          MYWM_WALLPAPER_DIRECTORY "${config.home.homeDirectory}/Pictures/Wallpapers"
          MYWM_LOCK_AFTER_SECONDS "600"
          MYWM_MONITOR_OFF_AFTER_SECONDS "6000"
          MYWM_TERMINAL_0 "${pkgs.kitty}/bin/kitty"
        }

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

        spawn-at-startup "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
        spawn-at-startup "${pkgs.networkmanagerapplet}/bin/nm-applet"
        spawn-at-startup "${shell}/bin/mywm-shell" "wallpaper"
        spawn-at-startup "${shell}/bin/mywm-shell" "bar"
        spawn-at-startup "${shell}/bin/mywm-shell" "idle"
        spawn-at-startup "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"

        hotkey-overlay {
          skip-at-startup
        }

        binds {
          Mod+Space {
            spawn "${shell}/bin/mywm-shell" "launcher";
          }

          Mod+Escape {
            spawn "${shell}/bin/mywm-shell" "lock";
          }

          Mod+Shift+W {
            spawn "${shell}/bin/mywm-shell" "wallpaper-picker";
          }
          Mod+Return {
            spawn "${pkgs.kitty}/bin/kitty";
          }

          Mod+B {
            spawn "${helium}/bin/helium";
          }

          Mod+F {
            spawn "${pkgs.nemo}/bin/nemo";
          }

          Mod+E {
            spawn "${pkgs.zed-editor}/bin/zeditor";
          }

          Mod+C {
            spawn "${chatgpt}/bin/chatgpt";
          }

          Mod+Ctrl+Shift+P {
            screenshot-screen;
          }

          Mod+Shift+P {
            screenshot;
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
            focus-workspace "1";
          }

          Mod+2 {
            focus-workspace "2";
          }

          Mod+3 {
            focus-workspace "3";
          }

          Mod+4 {
            focus-workspace "4";
          }

          Mod+5 {
            focus-workspace "5";
          }

          Mod+6 {
            focus-workspace "6";
          }

          Mod+7 {
            focus-workspace "7";
          }

          Mod+8 {
            focus-workspace "8";
          }

          Mod+9 {
            focus-workspace "9";
          }

          Mod+Shift+1 {
            move-column-to-workspace "1";
          }

          Mod+Shift+2 {
            move-column-to-workspace "2";
          }

          Mod+Shift+3 {
            move-column-to-workspace "3";
          }

          Mod+Shift+4 {
            move-column-to-workspace "4";
          }

          Mod+Shift+5 {
            move-column-to-workspace "5";
          }

          Mod+Shift+6 {
            move-column-to-workspace "6";
          }

          Mod+Shift+7 {
            move-column-to-workspace "7";
          }

          Mod+Shift+8 {
            move-column-to-workspace "8";
          }

          Mod+Shift+9 {
            move-column-to-workspace "9";
          }

          Mod+M {
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