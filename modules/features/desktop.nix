{ config, ... }:

{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [ config.flake.modules.homeManager.desktop ];

      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      hardware.graphics.enable = true;

      security.polkit.enable = true;
      security.rtkit.enable = true;

      programs.dconf.enable = true;

      services.graphical-desktop.enable = true;

      services.gvfs.enable = true;
      services.udisks2.enable = true;

      services.gnome.gnome-keyring.enable = true;

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
    };

  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      xdg.enable = true;

      xdg.userDirs = {
        enable = true;
        createDirectories = true;
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
        networkmanagerapplet
        wl-clipboard
        libnotify
      ];
    };
}
