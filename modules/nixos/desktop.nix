{ ... }:

{
  flake.modules.nixos.desktop =
    { pkgs, ... }:

    let
      opendeck = pkgs.callPackage ../../packages/opendeck.nix { };
    in

    {

      services.udev.packages = [
        opendeck
      ];

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
            "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session";

          user = "greeter";
        };
      };
    };
}
