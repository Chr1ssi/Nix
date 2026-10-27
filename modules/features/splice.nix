{ config, inputs, ... }:

let
  monitors = config.monitors;
in
{
  flake.modules.nixos.splice = _: {
    imports = [ inputs.splice.nixosModules.default ];

    home-manager.sharedModules = [ config.flake.modules.homeManager.splice ];

    programs.splice = {
      enable = true;
      greeterDirectory = "/persist/splice-greeter";
    };

    # The module routes screen sharing to splice-portal and the rest to GTK; secrets go to the keyring.
    xdg.portal.config.splice."org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  };

  perSystem =
    { pkgs, ... }:
    let
      splice = inputs.splice.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      packages = {
        inherit splice;
        default = splice;
      };
    };

  flake.modules.homeManager.splice =
    { config, pkgs, ... }:

    let
      screenshot = pkgs.writeShellApplication {
        name = "splice-screenshot";
        runtimeInputs = with pkgs; [
          grim
          libnotify
          slurp
          wl-clipboard
        ];
        text = ''
          screenshot_dir="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
          mkdir -p "$screenshot_dir"
          screenshot="$screenshot_dir/$(date +'%Y-%m-%d_%H-%M-%S').png"

          case "''${1:-full}" in
            full)
              grim "$screenshot"
              ;;
            region)
              selection=$(slurp) || exit 0
              grim -g "$selection" "$screenshot"
              ;;
            *)
              echo "Verwendung: splice-screenshot [full|region]" >&2
              exit 2
              ;;
          esac

          wl-copy --type image/png < "$screenshot"
          notify-send "Screenshot gespeichert" "$screenshot"
        '';
      };
      xwaylandPrimary = pkgs.writeShellApplication {
        name = "xwayland-primary-output";
        runtimeInputs = [ pkgs.xrandr ];
        text = ''
          for _ in {1..50}; do
            if xrandr --query 2>/dev/null | grep -q '^${monitors.main} connected'; then
              exec xrandr --output ${monitors.main} --primary
            fi
            sleep 0.2
          done

          echo '${monitors.main} wurde von XWayland nicht rechtzeitig erkannt.' >&2
          exit 1
        '';
      };
    in
    {
      # A plain file in the repo, linked out of the store so the settings editor (splice-settings)
      # can write it and the compositor reloads it live.
      xdg.configFile."splice/config.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects/nixos/dotfiles/splice/config.toml";

      home.packages = [
        screenshot
      ];

      systemd.user.services = {
        xwayland-primary-output = {
          Unit = {
            Description = "Mark the main output as the primary XWayland output";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${xwaylandPrimary}/bin/xwayland-primary-output";
            RemainAfterExit = true;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };

      home.file."Pictures/Wallpapers" = {
        source = ../../wallpapers;
        recursive = true;
      };
    };
}
