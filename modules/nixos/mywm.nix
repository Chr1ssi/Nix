{ inputs, ... }:

{
  flake.modules.nixos.mywm =
    { lib, pkgs, ... }:

    let
      mywm = inputs.mywm.packages.${pkgs.stdenv.hostPlatform.system}.default;

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
          max_fps = 60;

          chooser_cmd =
            "${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt='Bildschirm oder Fenster freigeben: ' --font='JetBrainsMono Nerd Font:size=12' --width=80 --lines=12 --minimal-lines --inner-pad=8 --background-color=1e1e2eff --text-color=cdd6f4ff --prompt-color=89b4faff --match-color=f5c2e7ff --selection-color=313244ff --selection-text-color=cdd6f4ff --selection-match-color=f5c2e7ff --border-width=2 --border-radius=0 --border-color=89b4faff";
        };
      };
    };
}
