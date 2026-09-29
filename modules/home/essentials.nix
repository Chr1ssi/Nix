{ ... }:

{
  flake.modules.homeManager.essentials =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      claude-desktop = pkgs.callPackage ../../packages/claude-desktop.nix { };
      chatgpt = pkgs.callPackage ../../packages/chatgpt-linux.nix { };
      helium = pkgs.callPackage ../../packages/helium.nix { };

      streamDeckIcon = name: "${config.xdg.dataHome}/streamdeck-icons/${name}.svg";
      streamDeckButton =
        {
          text,
          icon,
          command,
          backgroundColor ? "#ffffff",
        }:
        {
          state = 0;
          states."0" = {
            inherit text command;
            icon = streamDeckIcon icon;
            keys = "";
            write = "";
            brightness_change = 0;
            switch_page = 0;
            switch_state = 0;
            text_vertical_align = "middle-center";
            text_horizontal_align = "center";
            font = "";
            font_color = "#cdd6f4";
            font_size = 11;
            background_color = backgroundColor;
          };
        };
      emptyStreamDeckButton = {
        state = 0;
        states."0" = {
          text = "";
          icon = "";
          keys = "";
          write = "";
          command = "";
          brightness_change = 0;
          switch_page = 0;
          switch_state = 0;
          text_vertical_align = "";
          text_horizontal_align = "";
          font = "";
          font_color = "";
          font_size = 0;
          background_color = "";
        };
      };
      streamDeckConfig = pkgs.writeText "streamdeck-ui.json" (
        builtins.toJSON {
          state.DL22L2A34556 = {
            buttons."0" = {
              "0" = streamDeckButton {
                text = "ZURÜCK";
                icon = "previous";
                command = "playerctl previous";
              };
              "1" = streamDeckButton {
                text = "PLAY";
                icon = "play-pause";
                command = "playerctl play-pause";
              };
              "2" = streamDeckButton {
                text = "WEITER";
                icon = "next";
                command = "playerctl next";
              };
              "3" = streamDeckButton {
                text = "LEISER";
                icon = "volume-down";
                command = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
              };
              "4" = streamDeckButton {
                text = "LAUTER";
                icon = "volume-up";
                command = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
              };
              "5" = streamDeckButton {
                text = "VESKTOP";
                icon = "vesktop";
                command = "vesktop";
                backgroundColor = "#1e1e2e";
              };
              "6" = streamDeckButton {
                text = "HELIUM";
                icon = "helium";
                command = "helium";
                backgroundColor = "#1e1e2e";
              };
              "7" = streamDeckButton {
                text = "STEAM";
                icon = "steam";
                command = "steam";
                backgroundColor = "#1e1e2e";
              };
              "8" = streamDeckButton {
                text = "ZED";
                icon = "zed";
                command = "zeditor";
                backgroundColor = "#1e1e2e";
              };
              "9" = streamDeckButton {
                text = "HERMES";
                icon = "hermes";
                command = "hermes";
                backgroundColor = "#1e1e2e";
              };
              "10" = streamDeckButton {
                text = "BEREICH";
                icon = "screenshot-region";
                command = "mywm-screenshot region";
              };
              "11" = streamDeckButton {
                text = "VOLLBILD";
                icon = "screenshot-full";
                command = "mywm-screenshot full";
              };
              "12" = emptyStreamDeckButton;
              "13" = emptyStreamDeckButton;
              "14" = emptyStreamDeckButton;
            };
            display_timeout = 0;
            brightness = 99;
            brightness_dimmed = 0;
            rotation = 0;
            page = 0;
          };
          streamdeck_ui_version = 2;
        }
      );
    in

    {
      programs.git.enable = true;

      programs.kitty = {
        enable = true;
        extraConfig = builtins.replaceStrings
          [ "include themes/noctalia.conf" ]
          [ "include ${config.xdg.stateHome}/mywm/kitty.conf" ]
          (builtins.readFile ../../dotfiles/kitty/kitty.conf);
      };

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

      home.pointerCursor = {
        enable = true;
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
        size = 24;

        gtk.enable = true;
        x11.enable = true;
      };

      dconf.settings = {
        "org/nemo/preferences" = {
          close-device-view-on-device-eject = true;
          date-font-choice = "system-mono";
          show-compact-view-icon-toolbar = false;
          show-edit-icon-toolbar = false;
          show-full-path-titles = true;
          show-hidden-files = true;
          show-image-thumbnails = "always";
          swap-trash-delete = true;
        };

        "org/nemo/window-state" = {
          side-pane-view = "places";
          start-with-sidebar = true;
        };

        "org/gtk/gtk4/settings/file-chooser".show-hidden = true;
      };

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

      # Keep GUI edits possible, but seed the complete layout on a fresh home.
      home.activation.seedStreamDeckConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -e ${lib.escapeShellArg "${config.home.homeDirectory}/.streamdeck_ui.json"} ]; then
          run install -m 600 \
            ${streamDeckConfig} \
            ${lib.escapeShellArg "${config.home.homeDirectory}/.streamdeck_ui.json"}
        fi
      '';

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

      systemd.user.services.network-manager-applet = {
        Unit = {
          Description = "NetworkManager applet";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
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
        claude-desktop
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
