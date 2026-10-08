{ ... }:

{
  flake.modules.homeManager.theming =
    { config, pkgs, ... }:
    {
      gtk = {
        enable = true;

        theme = {
          name = "Nordic-darker";
          package = pkgs.nordic;
        };

        iconTheme = {
          name = "Slot-Nord-Dark-Colorize-Icons";
          package = pkgs.local.slot-nord-dark-colorize-icons;
        };

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = true;
          gtk-xft-antialias = 1;
          gtk-xft-hinting = 1;
          gtk-xft-hintstyle = "hintslight";
          gtk-xft-rgba = "rgb";
          gtk-toolbar-style = "GTK_TOOLBAR_ICONS";
          gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
          gtk-button-images = 0;
          gtk-menu-images = 0;
          gtk-enable-event-sounds = 1;
          gtk-enable-input-feedback-sounds = 0;
        };

        gtk3.extraCss = ''
          @import url("file://${config.xdg.stateHome}/mywm/gtk-3.css");
        '';

        gtk4.extraCss = ''
          @import url("file://${config.xdg.stateHome}/mywm/gtk-4.css");
        '';
      };

      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style.name = "kvantum";

        kvantum = {
          enable = true;
          themes = [ pkgs.nordic ];
          settings.General.theme = "Nordic-Darker";
        };

        qt5ctSettings.Appearance = {
          style = "kvantum";
          icon_theme = config.gtk.iconTheme.name;
        };
        qt6ctSettings.Appearance = {
          style = "kvantum";
          icon_theme = config.gtk.iconTheme.name;
        };
      };

      home.pointerCursor = {
        enable = true;
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
        size = 24;

        gtk.enable = true;
        x11.enable = true;
      };

      # Read by xdg-desktop-portal-gtk, so Electron/Chromium, libadwaita
      # and Firefox all pick up dark mode.
      dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };
}
