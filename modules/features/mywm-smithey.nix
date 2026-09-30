{ inputs, ... }:

{
  # Experimental second session: the Smithay compositor from MyWM-smithey with
  # the River mywm's bar, wallpaper and launcher. Needs the `mywm` module too.
  flake.modules.nixos.mywm-smithey =
    { pkgs, ... }:
    let
      compositor = pkgs.local.mywm-smithey;
      mywm = inputs.mywm.packages.${pkgs.stdenv.hostPlatform.system}.default;
      sessionEnvironment = pkgs.writeShellScript "mywm-session-environment" (
        builtins.readFile "${inputs.mywm}/scripts/session-environment"
      );

      # Runs inside the compositor once its Wayland socket exists (it is passed
      # as the startup command); the clients exit when the compositor does.
      startup = pkgs.writeShellScript "mywm-smithey-startup" ''
        wallpaper_state="''${XDG_STATE_HOME:-$HOME/.local/state}/mywm/wallpaper.json"
        ${mywm}/bin/mywm --theme-from-state "$wallpaper_state" \
          || echo 'Warnung: Theme konnte nicht aus dem Wallpaper erzeugt werden.' >&2
        ${sessionEnvironment} || echo 'Warnung: Portal-Umgebung unvollstaendig.' >&2
        ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
        ${mywm}/bin/mywm --wallpaper &
        ${mywm}/bin/mywm --bar &
        wait
      '';

      session = pkgs.writeShellApplication {
        name = "mywm-smithey-session";
        runtimeInputs = with pkgs; [
          compositor
          quickshell
          swaylock
          swayidle
          wlopm
          wlr-randr
          dbus
          systemd
          coreutils
        ];
        text = ''
          export XDG_CURRENT_DESKTOP=river
          export XDG_SESSION_DESKTOP=mywm-smithey
          export XDG_SESSION_TYPE=wayland
          export MYWM_BACKEND=drm
          export MYWM_SHELL_DIR=${mywm}/share/mywm/quickshell
          export MYWM_GREETER_DIR=/persist/mywm-greeter
          export MYWM_CONFIG="''${XDG_CONFIG_HOME:-$HOME/.config}/mywm/smithey.toml"

          log_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/mywm"
          mkdir -p "$log_dir"
          ipc_dir=$(mktemp -d "''${XDG_RUNTIME_DIR:?}/mywm-session.XXXXXX")
          export MYWM_SOCKET="$ipc_dir/control.sock"

          cleanup() {
            systemctl --user stop mywm-session.target 2>/dev/null || true
            rm -rf -- "$ipc_dir"
          }
          trap cleanup EXIT

          RUST_LOG="''${RUST_LOG:-info}" mywm-compositor ${startup} 2> "$log_dir/compositor.log"
        '';
      };

      sessionPackage =
        pkgs.runCommand "mywm-smithey-wayland-session" { passthru.providedSessions = [ "mywm-smithey" ]; }
          ''
            mkdir -p $out/share/wayland-sessions
            cat > $out/share/wayland-sessions/mywm-smithey.desktop <<EOF
            [Desktop Entry]
            Name=mywm (Smithay, experimentell)
            Comment=Eigener Smithay-Compositor mit der mywm-Quickshell-Oberflaeche
            Exec=${session}/bin/mywm-smithey-session
            Type=Application
            Keywords=tiling;wayland;compositor;
            EOF
          '';
    in
    {
      environment.systemPackages = [
        session
        compositor
      ];
      services.displayManager.sessionPackages = [ sessionPackage ];
    };
}
