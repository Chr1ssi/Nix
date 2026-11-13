{ ... }:

{
  flake.modules.homeManager.file-manager =
    { pkgs, ... }:
    {
      # Extracts and compresses archives itself, so no archive manager or extension is needed.
      home.packages = [ pkgs.cosmic-files ];

      dconf.settings."org/gtk/gtk4/settings/file-chooser".show-hidden = true;

      xdg.mimeApps = {
        enable = true;
        defaultApplications."inode/directory" = [ "com.system76.CosmicFiles.desktop" ];
      };
    };
}
