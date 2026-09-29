{ ... }:

{
  flake.modules.homeManager.theming =
    { config, pkgs, ... }:
    {
      gtk = {
        enable = true;

        theme = {
          name = "adw-gtk3";
          package = pkgs.adw-gtk3;
        };

        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
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
        platformTheme.name = "adwaita";
        style.name = "adwaita-dark";
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
