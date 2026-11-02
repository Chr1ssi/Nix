{ ... }:

{
  flake.modules.homeManager.file-manager =
    { pkgs, ... }:
    {
      home.packages = [
        # nemo-fileroller adds the "Extract Here" / "Extract to…" / "Compress…" context-menu entries.
        (pkgs.nemo-with-extensions.override {
          useDefaultExtensions = false;
          extensions = [ pkgs.nemo-fileroller ];
        })
        pkgs.file-roller
        # Space-bar quick look: Nemo calls the org.nemo.Preview D-Bus service, which is not a loadable extension.
        pkgs.nemo-preview
      ];

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

        # "Open in Terminal" runs this; the schema default is gnome-terminal, which is not installed.
        "org/cinnamon/desktop/applications/terminal".exec = "foot";

        "org/gtk/gtk4/settings/file-chooser".show-hidden = true;
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications."inode/directory" = [ "nemo.desktop" ];
      };
    };
}
