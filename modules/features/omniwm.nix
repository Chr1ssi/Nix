{ ... }:

{
  # OmniWM on macOS, modeled on mywm: scrolling columns, with the left Option key as Super.
  # The right Option key stays free for characters like @ [ ] { } | on the German layout.
  # Keys are matched by their QWERTY position: the German "+" key is "Right Bracket" and
  # the German "-" key is "Slash".
  flake.modules.homeManager.omniwm =
    { config, pkgs, ... }:
    let
      omniwmctl = "${config.programs.omniwm.package}/bin/omniwmctl";

      screenshot = pkgs.writeShellApplication {
        name = "omniwm-screenshot";
        text = ''
          screenshot_dir="$HOME/Pictures/Screenshots"
          mkdir -p "$screenshot_dir"
          screenshot="$screenshot_dir/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"

          case "''${1:-region}" in
            region)
              /usr/sbin/screencapture -i "$screenshot"
              ;;
            screen)
              /usr/sbin/screencapture -m "$screenshot"
              ;;
            window)
              window_id=$(${omniwmctl} query windows --focused --fields window-id --format tsv | tail -n +2) || true
              if [ -n "$window_id" ]; then
                /usr/sbin/screencapture -o -l"$window_id" "$screenshot"
              else
                /usr/sbin/screencapture -i -W -o "$screenshot"
              fi
              ;;
            *)
              echo "Verwendung: omniwm-screenshot [region|screen|window]" >&2
              exit 2
              ;;
          esac

          # Cancelled selection
          [ -f "$screenshot" ] || exit 0

          /usr/bin/osascript \
            -e "set the clipboard to (read (POSIX file \"$screenshot\") as «class PNGf»)" \
            -e "display notification \"$screenshot\" with title \"Screenshot gespeichert\""
        '';
      };
    in
    {
      programs.omniwm.enable = true;

      # Like mywm: a plain file in the repo, linked out of the store so the OmniWM settings
      # window can write it (OmniWM resolves the link) and OmniWM reloads it live.
      xdg.configFile."omniwm/settings.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/dotfiles/omniwm/settings.toml";

      home.packages = [ screenshot ];

      # OmniWM cannot launch programs and binds one key per action, so skhd covers
      # mywm's program_bindings, the screenshots and the second keys of focus and
      # workspace switching (through OmniWM's IPC).
      services.skhd = {
        enable = true;
        config = ''
          lalt - return : open -na kitty
          lalt - space : ${omniwmctl} command open-command-palette applications
          lalt - escape : pmset displaysleepnow

          lalt - b : open -a Safari
          lalt - f : open ~
          lalt - e : open -a Zed
          lalt - c : open -a Claude

          lalt - s : ${screenshot}/bin/omniwm-screenshot region
          lalt + shift - s : ${screenshot}/bin/omniwm-screenshot screen
          lalt + ctrl - s : ${screenshot}/bin/omniwm-screenshot window

          lalt - left : ${omniwmctl} command focus left
          lalt - down : ${omniwmctl} command focus down
          lalt - up : ${omniwmctl} command focus up
          lalt - right : ${omniwmctl} command focus right
          lalt + ctrl - up : ${omniwmctl} command switch-workspace prev
          lalt + ctrl - down : ${omniwmctl} command switch-workspace next
        '';
      };
    };
}
