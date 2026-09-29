{ config, ... }:

let
  monitors = config.monitors;
in
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    let
      greeterInit = pkgs.writeShellScript "greetd-river-init" ''
        ${pkgs.wlr-randr}/bin/wlr-randr --output ${monitors.main} --on --mode 2560x1440@143.973Hz --pos 0,0 --scale 1
        ${pkgs.wlr-randr}/bin/wlr-randr --output ${monitors.side} --off
        ${pkgs.wlr-randr}/bin/wlr-randr --output ${monitors.top} --off

        ${pkgs.river-classic}/bin/riverctl keyboard-layout de
        ${pkgs.river-classic}/bin/riverctl set-repeat 50 300
        ${pkgs.river-classic}/bin/riverctl input 'pointer-*' accel-profile flat
        ${pkgs.river-classic}/bin/riverctl input 'pointer-*' pointer-accel 0.0
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

      programs.streamdeck-ui = {
        enable = true;
        # mywm does not process XDG autostart entries. Home Manager
        # starts the controller as part of graphical-session.target instead.
        autoStart = false;
      };

      # mywm mirrors the current wallpaper and theme colors here (see
      # programs.mywm.greeterDirectory); the initial wallpaper is only a seed.
      systemd.tmpfiles.rules = [
        "d /persist/mywm-greeter 0755 chris users -"
        "C /persist/mywm-greeter/background 0644 chris users - ${../../wallpapers/wallhaven-1q2w63.jpg}"
      ];

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
          command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.river-classic}/bin/river -no-xwayland -c ${greeterInit}";

          user = "greeter";
        };
      };

      services.displayManager.regreet = {
        enable = true;

        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };

        extraCss = ''
          @import url("file:///persist/mywm-greeter/theme.css");

          window {
            color: @mywm_text;
          }

          frame.background {
            background-color: alpha(@mywm_bg, 0.94);
            border: 2px solid @mywm_accent;
            border-radius: 0;
            box-shadow: 0 12px 36px rgba(0, 0, 0, 0.55);
            padding: 12px;
          }

          entry,
          passwordentry,
          combobox button {
            background: @mywm_field;
            color: @mywm_text;
            border: 1px solid @mywm_border;
            border-radius: 0;
            min-height: 42px;
          }

          entry:focus,
          passwordentry:focus,
          combobox button:focus {
            border-color: @mywm_accent;
            box-shadow: 0 0 0 1px @mywm_accent;
          }

          button {
            background: @mywm_field;
            color: @mywm_text;
            border: 1px solid @mywm_border;
            border-radius: 0;
            min-height: 38px;
          }

          button:hover {
            background: @mywm_hover;
            border-color: @mywm_accent;
          }

          button.suggested-action {
            background: @mywm_accent;
            color: @mywm_on_accent;
            border-color: @mywm_accent;
          }

          button.destructive-action {
            background: @mywm_field;
            color: @mywm_error;
            border-color: @mywm_error;
          }
        '';

        settings = {
          GTK.application_prefer_dark_theme = true;
          appearance.greeting_msg = "Willkommen zurück!";
          background = {
            path = "/persist/mywm-greeter/background";
            fit = "Cover";
          };
          widget.clock = {
            format = "%a, %d. %b  %H:%M";
            resolution = "1s";
            locale = "de_DE";
            timezone = "Europe/Berlin";
          };
        };
      };
    };
}
