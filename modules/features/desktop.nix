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

      # On by default for graphical systems. Nothing here reads aloud; Vesktop only started it (~75 MB) to list voices.
      services.speechd.enable = false;

      services.gnome.gnome-keyring.enable = true;

      # Apps that ignore the request to quit (the Claude desktop app did) held up shutdown for the default 90 s.
      systemd.user.settings.Manager.DefaultTimeoutStopSec = "10s";

      fonts.packages = with pkgs; [
        nerd-fonts.iosevka-term
        noto-fonts
        noto-fonts-color-emoji
      ];

      # The system font: mywm's shell and settings app, and GTK/Qt apps, ask fontconfig for "Sans Serif".
      fonts.fontconfig.defaultFonts.sansSerif = [ "IosevkaTerm Nerd Font Propo" ];
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
