{
  # The way from power-on to the greeter in the session's look: Limine on a blurred, darkened wallpaper in the
  # theme's colors, then Plymouth instead of kernel and systemd messages.
  flake.modules.nixos.boot-theme =
    { pkgs, ... }:
    let
      # The boot menu cannot follow wallpaper changes (it is written to the EFI partition at rebuild time), so it
      # keeps this picture and the colors mywm generated from it (~/.local/state/mywm/theme.json at the time).
      wallpaper = pkgs.runCommand "limine-wallpaper.jpg" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
        magick ${../../wallpapers/wallhaven-q6omvd.jpg} -resize 2560x1440^ -gravity center -extent 2560x1440 \
          -blur 0x14 -fill black -colorize 45% -quality 92 $out
      '';
      colors = {
        surface = "111413";
        container = "262827";
        text = "ffffff";
        muted = "d5dedb";
        outline = "89928f";
        primary = "b1e7db";
        secondary = "cce1db";
        tertiary = "ded8ff";
        error = "ffd2cc";
      };
    in
    {
      boot.loader.limine.style = with colors; {
        wallpapers = [ wallpaper ];
        wallpaperStyle = "stretched";
        interface = {
          branding = "NixOS";
          brandingColor = primary;
          helpColor = outline;
        };
        graphicalTerminal = {
          font.scale = "2x2";
          # A large margin turns the menu into a panel in the middle of the picture.
          margin = 280;
          marginGradient = 24;
          # TT of TTRRGGBB is transparency: a little of the picture shows through, like the shell's glass.
          background = "30${surface}";
          foreground = muted;
          brightBackground = container;
          brightForeground = text;
          # black, red, green, brown, blue, magenta, cyan, gray (and their bright variants)
          palette = "${surface};${error};${primary};${tertiary};${primary};${tertiary};${secondary};${muted}";
          brightPalette = "${outline};${error};${primary};${tertiary};${primary};${tertiary};${secondary};${text}";
        };
      };

      boot.plymouth = {
        enable = true;
        theme = "nixos-bgrt";
        themePackages = [ pkgs.nixos-bgrt-plymouth ];
      };
      # Messages only when something goes wrong; Plymouth shows the rest.
      boot.consoleLogLevel = 3;
      boot.initrd.verbose = false;
      # "splash" comes with Plymouth.
      boot.kernelParams = [
        "quiet"
        "udev.log_level=3"
        "systemd.show_status=auto"
      ];
    };
}
