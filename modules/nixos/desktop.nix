{ lib, pkgs, mywm, ... }:
let
  sessionEnvironment = pkgs.writeShellScript "mywm-session-environment"
    (builtins.readFile ./scripts/session-environment);
  riverInit = pkgs.writeShellScript "mywm-river-init"
    (builtins.readFile ./scripts/river-init);
  session = pkgs.writeShellApplication {
    name = "mywm-session";
    runtimeInputs = with pkgs; [
      river mywm kanshi quickshell swaylock swayidle wlopm
      dbus systemd coreutils bash dunst zenity
    ];
    text = ''
      export XDG_CURRENT_DESKTOP=river
      export XDG_SESSION_DESKTOP=mywm
      export XDG_SESSION_TYPE=wayland
      export MYWM_BINARY=${mywm}/bin/mywm
      export MYWM_SHELL_DIR=${mywm}/share/mywm/quickshell
      export MYWM_POLKIT_AGENT=${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
      export MYWM_SESSION_ENVIRONMENT=${sessionEnvironment}
      export MYWM_CONFIG="''${XDG_CONFIG_HOME:-$HOME/.config}/mywm/config.toml"
      export MYWM_MONITOR_CONFIG="''${XDG_CONFIG_HOME:-$HOME/.config}/kanshi/config"
      exec river -c ${riverInit}
    '';
  };
in {
  assertions = [ {
    assertion = lib.versionAtLeast pkgs.river.version "0.4";
    message = "mywm requires River >= 0.4 (not river-classic). Update nixpkgs if necessary.";
  } ];
  environment.systemPackages = [ session mywm pkgs.river ];
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  hardware.graphics.enable = true;
  security.polkit.enable = true;
  security.rtkit.enable = true;
  security.pam.services.swaylock = {};
  programs.dconf.enable = true;
  programs.xwayland.enable = true;
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
  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono noto-fonts noto-fonts-color-emoji ];
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.river = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
    };
    wlr.settings.screencast = {
      chooser_type = "dmenu";
      chooser_cmd = "${pkgs.zenity}/bin/zenity --list --title='Bildschirm oder Fenster freigeben' --column='Quelle' --width=800 --height=500";
    };
  };
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${session}/bin/mywm-session";
      user = "greeter";
    };
  };
}
