{ config, ... }:

{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [ config.flake.modules.homeManager.desktop ];

      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      security.polkit.enable = true;
      security.rtkit.enable = true;

      programs.dconf.enable = true;

      services.gvfs.enable = true;
      services.udisks2.enable = true;

      services.gnome.gnome-keyring.enable = true;

      # Apps that ignore the request to quit (the Claude desktop app did) held up shutdown for the default 90 s.
      systemd.user.settings.Manager.DefaultTimeoutStopSec = "10s";

      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        noto-fonts
        noto-fonts-color-emoji
      ];
    };

  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      xdg.enable = true;

      xdg.userDirs = {
        enable = true;
        createDirectories = true;
      };

      home.packages = with pkgs; [
        wl-clipboard
        libnotify
      ];
    };
}
