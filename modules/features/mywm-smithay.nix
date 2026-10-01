{ inputs, ... }:

{
  # Second session: the Smithay compositor from MyWM-Smithay. Its own NixOS
  # module is not imported because it defines programs.mywm and the session "mywm" like the
  # River mywm module does; this takes the packages and adds a separate session. The
  # `mywm` module still provides mywm-session.target, Xwayland and the swaylock PAM service.
  flake.modules.nixos.mywm-smithay =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      mywm = inputs.mywm-smithay.packages.${system}.default;
      # Needs an editable config: smithay.toml is linked to dotfiles/mywm (see the mywm module).
      settings = inputs.mywm-smithay.packages.${system}.mywm-settings;

      launch = pkgs.writeShellScript "mywm-smithay-launch" ''
        # Everything the session prints (also errors of the helpers before the compositor
        # has the screen) goes to a file: the previous session's stays as session.log.1.
        state="''${XDG_STATE_HOME:-$HOME/.local/state}/mywm"
        mkdir -p "$state"
        mv -f "$state/session.log" "$state/session.log.1" 2>/dev/null
        exec > "$state/session.log" 2>&1
        echo "$(date --iso-8601=ns) session launch, pid $$"
        export XDG_CURRENT_DESKTOP=mywm
        export XDG_SESSION_DESKTOP=mywm-smithay
        export XDG_SESSION_TYPE=wayland
        export MYWM_SHELL_DIR=${mywm}/share/mywm/quickshell
        export MYWM_POLKIT_AGENT=${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
        export MYWM_GREETER_DIR=/persist/mywm-greeter
        # Every 5 s per output: frames, CPU render time and frames slower than the refresh interval.
        export RUST_LOG="''${RUST_LOG:-info,perf=debug}"
        export MYWM_CONFIG="''${XDG_CONFIG_HOME:-$HOME/.config}/mywm/smithay.toml"
        exec ${mywm}/bin/mywm-session
      '';

      sessionPackage =
        pkgs.runCommand "mywm-smithay-wayland-session" { passthru.providedSessions = [ "mywm-smithay" ]; }
          ''
            mkdir -p $out/share/wayland-sessions
            cat > $out/share/wayland-sessions/mywm-smithay.desktop <<EOF
            [Desktop Entry]
            Name=mywm (Smithay)
            Comment=Eigener Smithay-Compositor mit der mywm-Quickshell-Oberflaeche
            Exec=${launch}
            Type=Application
            DesktopNames=mywm
            Keywords=tiling;wayland;compositor;
            EOF
          '';
    in
    {
      environment.systemPackages = [
        mywm
        settings
      ];
      services.displayManager.sessionPackages = [ sessionPackage ];

      # XDG_CURRENT_DESKTOP=mywm: screen sharing goes through mywm-portal (the compositor
      # asks what to share), the rest through the GTK portal and the keyring.
      xdg.portal = {
        extraPortals = [ mywm ];
        config.mywm = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "mywm" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      };
      services.pipewire.enable = true;
    };
}
