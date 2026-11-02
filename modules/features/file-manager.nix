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

        "org/gtk/gtk4/settings/file-chooser".show-hidden = true;
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications."inode/directory" = [ "nemo.desktop" ];
      };
    };
}
