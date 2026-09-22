{ ... }:

{
  flake.modules.homeManager.essentials =
    { pkgs, ... }:

    let
      helium = pkgs.callPackage ../../packages/helium.nix { };
    in

    {
      programs.git.enable = true;
      programs.firefox.enable = true;

      programs.kitty = {
        enable = true;
        extraConfig =
          builtins.readFile ../../dotfiles/kitty/kitty.conf;
      };

      xdg.configFile."kitty/themes/noctalia.conf".source =
        ../../dotfiles/kitty/themes/noctalia.conf;

      gtk = {
        enable = true;

        theme = {
          name = "adw-gtk3";
          package = pkgs.adw-gtk3;
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

        gtk3.extraCss =
          builtins.readFile ../../dotfiles/gtk-3.0/gtk.css;

        gtk4.extraCss =
          builtins.readFile ../../dotfiles/gtk-4.0/gtk.css;
      };

      home.pointerCursor = {
        enable = true;
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
        size = 24;

        gtk.enable = true;
        x11.enable = true;
      };

      xdg.configFile."gtk-3.0/noctalia.css".source =
        ../../dotfiles/gtk-3.0/noctalia.css;

      xdg.configFile."gtk-4.0/noctalia.css".source =
        ../../dotfiles/gtk-4.0/noctalia.css;

      home.packages = with pkgs; [
        nautilus
        mpv
        imv
        pavucontrol
        networkmanagerapplet
        wl-clipboard
        libnotify
        helium
      ];

      xdg.enable = true;

      xdg.userDirs = {
        enable = true;
        createDirectories = true;
      };

      xdg.mimeApps = {
        enable = true;

        defaultApplications = {
          "text/html" = [ "helium.desktop" ];
          "x-scheme-handler/http" = [ "helium.desktop" ];
          "x-scheme-handler/https" = [ "helium.desktop" ];
          "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
        };
      };

      services.dunst.enable = true;
    };
}
