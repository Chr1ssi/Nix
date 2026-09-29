{ inputs, ... }:

{
  flake.modules.nixos.mywm =
    { pkgs, ... }:
    {
      imports = [ inputs.mywm.nixosModules.default ];

      programs.mywm = {
        enable = true;
        greeterDirectory = "/persist/mywm-greeter";
      };

      xdg.portal = {
        config.river."org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];

        wlr.settings.screencast = {
          max_fps = 60;

          chooser_cmd = "${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt='Bildschirm oder Fenster freigeben: ' --font='JetBrainsMono Nerd Font:size=12' --width=80 --lines=12 --minimal-lines --inner-pad=8 --background-color=1e1e2eff --text-color=cdd6f4ff --prompt-color=89b4faff --match-color=f5c2e7ff --selection-color=313244ff --selection-text-color=cdd6f4ff --selection-match-color=f5c2e7ff --border-width=2 --border-radius=0 --border-color=89b4faff";
        };
      };
    };
}
