{
  # greetd with splice's own login screen (drawn by `splice-compositor --greeter` itself), in the look of the lock
  # screen.
  flake.modules.nixos.greeter =
    { pkgs, ... }:
    let
      # The session's own configuration: the login screen uses its monitors, keyboard and input.
      session = builtins.fromTOML (builtins.readFile ../../dotfiles/splice/config.toml);
    in
    {
      # splice mirrors the current wallpaper and theme colors here (see
      # programs.splice.greeterDirectory); the initial wallpaper is only a seed.
      systemd.tmpfiles.rules = [
        "d /persist/splice-greeter 0755 chris users -"
        "C /persist/splice-greeter/background 0644 chris users - ${../../wallpapers/wallhaven-1q2w63.jpg}"
      ];

      security.pam.services.greetd.enableGnomeKeyring = true;

      programs.splice.greeter = {
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
          # The look (cyberdeck or default); the colors come from the synced theme.
          appearance = { inherit (session.appearance) style; };
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
