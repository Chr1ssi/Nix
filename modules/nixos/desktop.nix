{ ... }:

{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    let
      greeterInit = pkgs.writeShellScript "greetd-river-init" ''
        ${pkgs.wlr-randr}/bin/wlr-randr \
          --output DP-3 --on --mode 2560x1440@143.97Hz --pos 0,0 --scale 1 \
          --output DP-1 --off \
          --output HDMI-A-1 --off

        ${pkgs.river-classic}/bin/riverctl keyboard-layout de
        ${pkgs.river-classic}/bin/riverctl set-repeat 50 300
        ${pkgs.river-classic}/bin/riverctl default-layout rivertile
        ${pkgs.river-classic}/bin/rivertile -view-padding 0 -outer-padding 0 &

        ${pkgs.regreet}/bin/regreet
        ${pkgs.river-classic}/bin/riverctl exit
      '';
    in
    {

      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      hardware.graphics.enable = true;

      security.polkit.enable = true;
      security.rtkit.enable = true;

      programs.dconf.enable = true;

      services.graphical-desktop.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };

      services.gvfs.enable = true;
      services.udisks2.enable = true;

      services.udev.packages = [ pkgs.streamcontroller ];

      services.gnome.gnome-keyring.enable = true;
      security.pam.services.greetd.enableGnomeKeyring = true;

      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        noto-fonts
        noto-fonts-color-emoji
      ];

      xdg.portal = {
        enable = true;

        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];
      };

      services.greetd = {
        enable = true;

        settings.default_session = {
          command =
            "${pkgs.dbus}/bin/dbus-run-session ${pkgs.river-classic}/bin/river -no-xwayland -c ${greeterInit}";

          user = "greeter";
        };
      };

      services.displayManager.regreet = {
        enable = true;

        settings = {
          GTK.application_prefer_dark_theme = true;
          appearance.greeting_msg = "Willkommen zurück!";
          widget.clock = {
            format = "%a, %d. %b  %H:%M";
            resolution = "1s";
          };
        };
      };
    };
}
