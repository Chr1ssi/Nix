{ ... }:

{
  flake.modules.homeManager.essentials =
    { pkgs, ... }:

    let
      chatgpt = pkgs.callPackage ../../packages/chatgpt-linux.nix { };
      helium = pkgs.callPackage ../../packages/helium.nix { };
    in

    {
      programs.git.enable = true;

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

      xdg.dataFile."easyeffects/input/Wave3 Clean.json".source =
        ../../dotfiles/easyeffects/input/Wave3-Clean.json;

      xdg.dataFile."streamdeck-icons/previous.svg".source =
        "${pkgs.papirus-icon-theme}/share/icons/Papirus/24x24/actions/media-skip-backward.svg";
      xdg.dataFile."streamdeck-icons/play-pause.svg".source =
        "${pkgs.papirus-icon-theme}/share/icons/Papirus/24x24/actions/media-playback-start.svg";
      xdg.dataFile."streamdeck-icons/next.svg".source =
        "${pkgs.papirus-icon-theme}/share/icons/Papirus/24x24/actions/media-skip-forward.svg";
      xdg.dataFile."streamdeck-icons/volume-down.svg".source =
        "${pkgs.papirus-icon-theme}/share/icons/Papirus/24x24/actions/audio-volume-low.svg";
      xdg.dataFile."streamdeck-icons/volume-up.svg".source =
        "${pkgs.papirus-icon-theme}/share/icons/Papirus/24x24/actions/audio-volume-high.svg";
      xdg.dataFile."streamdeck-icons/vesktop.svg".source =
        "${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps/vesktop.svg";
      xdg.dataFile."streamdeck-icons/helium.svg".source =
        "${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps/net.imput.helium.svg";
      xdg.dataFile."streamdeck-icons/steam.svg".source =
        "${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps/steam.svg";
      xdg.dataFile."streamdeck-icons/zed.svg".source =
        "${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps/zed.svg";
      xdg.dataFile."streamdeck-icons/hermes.svg".source =
        "${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps/gnome-robots.svg";
      xdg.dataFile."streamdeck-icons/screenshot-region.svg".source =
        "${pkgs.papirus-icon-theme}/share/icons/Papirus/24x24/actions/image-crop.svg";
      xdg.dataFile."streamdeck-icons/screenshot-full.svg".source =
        "${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/devices/camera-photo.svg";

      systemd.user.services.streamdeck-ui = {
        Unit = {
          Description = "Stream Deck controller";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = "${pkgs.streamdeck-ui}/bin/streamdeck --no-ui";
          Restart = "on-failure";
          RestartSec = 2;
        };

        Install.WantedBy = [ "graphical-session.target" ];
      };

      home.packages = with pkgs; [
        easyeffects
        nemo
        mpv
        imv
        pavucontrol
        playerctl
        networkmanagerapplet
        wl-clipboard
        libnotify
        helium
        chatgpt
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
          "inode/directory" = [ "nemo.desktop" ];
        };
      };
    };
}
