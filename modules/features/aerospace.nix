{ ... }:

{
  # AeroSpace on macOS, with key bindings modeled on dotfiles/mywm/config.toml.
  #
  # Super becomes ctrl+alt: alt alone would swallow characters on the German layout
  # (alt-l = @, alt-5..9 = [ ] | { }) and cmd collides with almost every app shortcut.
  # mywm's Super+Ctrl becomes ctrl+alt+cmd, as ctrl is already part of Super.
  # Keys are matched by their QWERTY position, so the German "+" key is rightSquareBracket
  # and the German "-" key is slash.
  flake.modules.homeManager.aerospace =
    { lib, ... }:
    let
      workspaces = map toString (lib.range 1 9);
      super = "ctrl-alt";
      superShift = "ctrl-alt-shift";
      superCtrl = "ctrl-alt-cmd";
      superCtrlShift = "ctrl-alt-cmd-shift";

      openApp = app: "exec-and-forget open -a '${app}'";
    in
    {
      programs.aerospace = {
        enable = true;
        launchd.enable = true;

        settings = {
          default-root-container-layout = "tiles";
          default-root-container-orientation = "auto";

          on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

          # appearance.gaps_inner / gaps_outer
          gaps = {
            inner.horizontal = 4;
            inner.vertical = 4;
            outer.left = 4;
            outer.bottom = 4;
            outer.top = 4;
            outer.right = 4;
          };

          mode.main.binding = {
            "${superShift}-r" = "reload-config";
            "${super}-esc" = "exec-and-forget pmset displaysleepnow";
            "${super}-enter" = "exec-and-forget open -na kitty";
            "${super}-q" = "close";
            "${super}-v" = "layout floating tiling";
            "${superShift}-f" = "fullscreen";

            # program_bindings
            "${super}-b" = openApp "Safari";
            "${super}-f" = "exec-and-forget open ~";
            "${super}-e" = openApp "Zed";
            "${super}-c" = openApp "Claude";

            # Focus crosses monitor edges, which also covers mywm's focus_output_*.
            "${super}-h" = "focus --boundaries all-monitors-outer-frame left";
            "${super}-j" = "focus --boundaries all-monitors-outer-frame down";
            "${super}-k" = "focus --boundaries all-monitors-outer-frame up";
            "${super}-l" = "focus --boundaries all-monitors-outer-frame right";
            "${super}-left" = "focus --boundaries all-monitors-outer-frame left";
            "${super}-down" = "focus --boundaries all-monitors-outer-frame down";
            "${super}-up" = "focus --boundaries all-monitors-outer-frame up";
            "${super}-right" = "focus --boundaries all-monitors-outer-frame right";

            "${superShift}-h" = "move left";
            "${superShift}-j" = "move down";
            "${superShift}-k" = "move up";
            "${superShift}-l" = "move right";

            "${superShift}-left" = "move-node-to-monitor --focus-follows-window left";
            "${superShift}-down" = "move-node-to-monitor --focus-follows-window down";
            "${superShift}-up" = "move-node-to-monitor --focus-follows-window up";
            "${superShift}-right" = "move-node-to-monitor --focus-follows-window right";

            "${superCtrl}-left" = "workspace --wrap-around prev";
            "${superCtrl}-up" = "workspace --wrap-around prev";
            "${superCtrl}-right" = "workspace --wrap-around next";
            "${superCtrl}-down" = "workspace --wrap-around next";
            "${superCtrlShift}-up" = "move-node-to-workspace --focus-follows-window --wrap-around prev";
            "${superCtrlShift}-down" = "move-node-to-workspace --focus-follows-window --wrap-around next";

            # column_grow, plus the matching shrink
            "${super}-rightSquareBracket" = "resize smart +50";
            "${super}-slash" = "resize smart -50";
          }
          // lib.listToAttrs (
            lib.concatMap (ws: [
              (lib.nameValuePair "${super}-${ws}" "workspace ${ws}")
              (lib.nameValuePair "${superShift}-${ws}" "move-node-to-workspace ${ws}")
            ]) workspaces
          );
        };
      };
    };
}
