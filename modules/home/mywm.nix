{ ... }:

{
  flake.modules.homeManager.mywm =
    { config, pkgs, ... }:

    let
      toml = pkgs.formats.toml { };
    in
    {
      xdg.configFile."mywm/config.toml".source =
        toml.generate "mywm.toml" {
          workspaces = 9;
          float_dialogs = true;

          terminal = [
            "${pkgs.kitty}/bin/kitty"
          ];

          autostart = [
            [ "${pkgs.networkmanagerapplet}/bin/nm-applet" ]
          ];

          program_bindings = {
            browser = {
              keys = [ "Super+b" ];
              command = [ "${pkgs.firefox}/bin/firefox" ];
            };

            file_manager = {
              keys = [ "Super+e" ];
              command = [ "${pkgs.nautilus}/bin/nautilus" ];
            };
          };

          wallpaper_directory =
            "${config.home.homeDirectory}/Pictures/Wallpapers";

          keyboard = {
            layout = "de";
            variant = "";
            options = "";
          };

          idle = {
            lock_after_seconds = 600;
            monitor_off_after_seconds = 6000;
          };

          appearance = {
            gaps_inner = 4;
            gaps_outer = 4;
            border_width = 2;

            active_border = "#89b4fa";
            inactive_border = "#45475a";

            background = "#1e1e2e";
            surface = "#313244";

            text = "#cdd6f4";
            muted_text = "#a6adc8";
          };

          rules = [
            {
              dialog = true;
              floating = true;
            }
          ];
        };

      xdg.configFile."kanshi/config".text =
        "# Keep River's default output configuration.\n";

        home.file."Pictures/Wallpapers" = {
          source = ../../wallpapers;
          recursive = true;
        };
    };
}
