{ ... }:

{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
        package = pkgs.steam.override { extraEnv.PROTON_ENABLE_WAYLAND = "1"; };
      };

      hardware.graphics.enable32Bit = true;
      services.pipewire.alsa.support32Bit = true;

      programs.gamemode.enable = true;

      home-manager.users.chris =
        { config, lib, ... }:
        {
          home.packages = with pkgs; [
            faugus-launcher
            mangohud
            heroic
            prismlauncher
            vesktop
          ];

          # Vesktop replaces the link with a file of its own whenever it saves its settings.
          xdg.configFile."vesktop/settings.json" = {
            source = ../../dotfiles/vesktop/settings.json;
            force = true;
          };

          xdg.configFile."vesktop/settings/settings.json" = {
            source = ../../dotfiles/vesktop/vencord-settings.json;
            force = true;
          };

          xdg.configFile."vesktop/settings/quickCss.css" = {
            source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.stateHome}/splice/vesktop.css";
            force = true;
          };

          home.activation.seedGamingConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            run mkdir -p \
              ${lib.escapeShellArg "${config.xdg.configHome}/MangoHud"} \

            if [ ! -e ${lib.escapeShellArg "${config.xdg.configHome}/MangoHud/MangoHud.conf"} ]; then
              run install -m 644 \
                ${../../dotfiles/MangoHud/MangoHud.conf} \
                ${lib.escapeShellArg "${config.xdg.configHome}/MangoHud/MangoHud.conf"}
            fi
          '';
        };
    };
}
