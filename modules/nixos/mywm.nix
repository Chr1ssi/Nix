{ inputs, ... }:

{
  flake.modules.nixos.mywm =
    { lib, pkgs, ... }:

    let
      mywm = pkgs.callPackage ../../packages/mywm.nix {
        src = inputs.mywm-src;
        shellSrc = inputs.mywm-shell-src;
      };

      sessionEnvironment =
        pkgs.writeShellScript
          "mywm-session-environment"
          (builtins.readFile ../../scripts/session-environment);

      riverInit =
        pkgs.writeShellScript
          "mywm-river-init"
          (builtins.readFile ../../scripts/river-init);

      session = pkgs.writeShellApplication {
        name = "mywm-session";

        runtimeInputs = with pkgs; [
          river
          mywm
          kanshi
          quickshell
          swaylock
          swayidle
          wlopm
          dbus
          systemd
          coreutils
          bash
          zenity
        ];

        text = ''
          export XDG_CURRENT_DESKTOP=river
          export XDG_SESSION_DESKTOP=mywm
          export XDG_SESSION_TYPE=wayland

          export MYWM_BINARY=${mywm}/bin/mywm
          export MYWM_SHELL_DIR=${mywm}/share/mywm/quickshell
          export MYWM_POLKIT_AGENT=${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
          export MYWM_SESSION_ENVIRONMENT=${sessionEnvironment}
          export MYWM_CONFIG="''${XDG_CONFIG_HOME:-$HOME/.config}/mywm/config.toml"
          export MYWM_MONITOR_CONFIG="''${XDG_CONFIG_HOME:-$HOME/.config}/kanshi/config"

          exec river -c ${riverInit}
        '';
      };

      mywmSession = pkgs.runCommand "mywm-wayland-session"
      {
        passthru.providedSessions = [ "mywm" ];
      }
      ''
        mkdir -p $out/share/wayland-sessions

        cat > $out/share/wayland-sessions/mywm.desktop <<EOF
        [Desktop Entry]
        Name=mywm
        Comment=Custom River-based Wayland session
        Exec=${session}/bin/mywm-session
        Type=Application
        DesktopNames=river
        EOF
      '';
    in
    {
      assertions = [
        {
          assertion =
            lib.versionAtLeast pkgs.river.version "0.4";

          message =
            "mywm requires River >= 0.4 (not river-classic).";
        }
      ];

      environment.systemPackages = [
        session
        mywm
        pkgs.river
      ];

      services.displayManager.sessionPackages = [
        mywmSession
      ];

      security.pam.services.swaylock = { };

      programs.xwayland.enable = true;

      xdg.portal = {
        wlr.enable = true;

        config.river = {
          default = [ "gtk" ];

          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        };

        wlr.settings.screencast = {
          chooser_type = "dmenu";

          chooser_cmd =
            "${pkgs.zenity}/bin/zenity --list --title='Bildschirm oder Fenster freigeben' --column='Quelle' --width=800 --height=500";
        };
      };
    };
}
