{ ... }:

{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    let
      greeterInit = pkgs.writeShellScript "greetd-river-init" ''
        ${pkgs.wlr-randr}/bin/wlr-randr --output DP-3 --on --mode 2560x1440@143.973Hz --pos 0,0 --scale 1
        ${pkgs.wlr-randr}/bin/wlr-randr --output DP-1 --off
        ${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --off

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

        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };

        extraCss = ''
          window {
            color: #cdd6f4;
          }

          frame.background {
            background-color: rgba(30, 30, 46, 0.94);
            border: 2px solid #89b4fa;
            border-radius: 0;
            box-shadow: 0 12px 36px rgba(0, 0, 0, 0.55);
            padding: 12px;
          }

          entry,
          passwordentry,
          combobox button {
            background: #313244;
            color: #cdd6f4;
            border: 1px solid #45475a;
            border-radius: 0;
            min-height: 42px;
          }

          entry:focus,
          passwordentry:focus,
          combobox button:focus {
            border-color: #89b4fa;
            box-shadow: 0 0 0 1px #89b4fa;
          }

          button {
            background: #313244;
            color: #cdd6f4;
            border: 1px solid #45475a;
            border-radius: 0;
            min-height: 38px;
          }

          button:hover {
            background: #45475a;
            border-color: #89b4fa;
          }

          button.suggested-action {
            background: #89b4fa;
            color: #1e1e2e;
            border-color: #89b4fa;
          }

          button.destructive-action {
            background: #313244;
            color: #f38ba8;
            border-color: #f38ba8;
          }
        '';

        settings = {
          GTK.application_prefer_dark_theme = true;
          appearance.greeting_msg = "Willkommen zurück!";
          background = {
            path = ../../wallpapers/wallhaven-1q2w63.jpg;
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
