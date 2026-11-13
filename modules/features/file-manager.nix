{ ... }:

{
  flake.modules.homeManager.file-manager =
    { pkgs, ... }:
    {
      # Extracts and compresses archives itself, so no archive manager or extension is needed.
      home.packages = [ pkgs.cosmic-files ];

      dconf.settings."org/gtk/gtk4/settings/file-chooser".show-hidden = true;

      # The defaults cosmic-config reads until the app's settings say otherwise.
      xdg.dataFile."cosmic/com.system76.CosmicFiles/v1/tab".text = "(show_hidden: true)";

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = [ "com.system76.CosmicFiles.desktop" ];
          # "Open in Terminal" asks for this; without it, it takes the first terminal entry it finds, which can be foot's server.
          "x-scheme-handler/terminal" = [ "foot.desktop" ];
        };
      };
    };
}
