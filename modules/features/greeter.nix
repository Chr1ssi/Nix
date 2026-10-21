{
  # greetd with mywm's own login screen (drawn by `mywm-compositor --greeter` itself), in the look of the lock
  # screen.
  flake.modules.nixos.greeter =
    { pkgs, ... }:
    let
      # The session's own configuration: the login screen uses its monitors, keyboard and input.
      session = builtins.fromTOML (builtins.readFile ../../dotfiles/mywm/config.toml);
    in
    {
      # mywm mirrors the current wallpaper and theme colors here (see
      # programs.mywm.greeterDirectory); the initial wallpaper is only a seed.
      systemd.tmpfiles.rules = [
        "d /persist/mywm-greeter 0755 chris users -"
        "C /persist/mywm-greeter/background 0644 chris users - ${../../wallpapers/wallhaven-1q2w63.jpg}"
      ];

      security.pam.services.greetd.enableGnomeKeyring = true;

      programs.mywm.greeter = {
        enable = true;
        user = "chris";
        # workspace_outputs: the card goes to the monitor with workspace 1.
        settings = {
          inherit (session)
            keyboard
            input
            outputs
            workspace_outputs
            ;
        };
        # The cursor of the session (home-manager's pointerCursor), which the greeter user does not have.
        environment = {
          XCURSOR_THEME = "Bibata-Modern-Ice";
          XCURSOR_SIZE = "24";
          XCURSOR_PATH = "${pkgs.bibata-cursors}/share/icons";
        };
      };
    };
}
