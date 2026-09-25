{ ... }:

{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      programs.steam.enable = true;

      hardware.graphics.enable32Bit = true;
      services.pipewire.alsa.support32Bit = true;

      programs.gamemode.enable = true;

      home-manager.users.chris =
        { config, lib, ... }:
        {
          home.packages = with pkgs; [
            faugus-launcher
            goverlay
            heroic
            prismlauncher
            vesktop
          ];

          xdg.configFile."vesktop/settings.json".source =
            ../../dotfiles/vesktop/settings.json;

          home.activation.seedGamingConfigs =
            lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              run mkdir -p \
                ${lib.escapeShellArg "${config.xdg.configHome}/MangoHud"} \
                ${lib.escapeShellArg "${config.xdg.configHome}/goverlay"}

              if [ ! -e ${lib.escapeShellArg "${config.xdg.configHome}/MangoHud/MangoHud.conf"} ]; then
                run install -m 644 \
                  ${../../dotfiles/MangoHud/MangoHud.conf} \
                  ${lib.escapeShellArg "${config.xdg.configHome}/MangoHud/MangoHud.conf"}
              fi

              if [ ! -e ${lib.escapeShellArg "${config.xdg.configHome}/goverlay/blacklist.conf"} ]; then
                run install -m 644 \
                  ${../../dotfiles/goverlay/blacklist.conf} \
                  ${lib.escapeShellArg "${config.xdg.configHome}/goverlay/blacklist.conf"}
              fi

              if [ ! -e ${lib.escapeShellArg "${config.xdg.configHome}/goverlay/goverlay.conf"} ]; then
                run install -m 644 \
                  ${../../dotfiles/goverlay/goverlay.conf} \
                  ${lib.escapeShellArg "${config.xdg.configHome}/goverlay/goverlay.conf"}
              fi
            '';
        };
    };
}
