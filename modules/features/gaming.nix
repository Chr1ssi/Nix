{ ... }:

{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    let
      # Unter Wayland wartet Vesktop vor jeder Freigabe auf ein Thumbnail (1920x1080), das
      # es danach gar nicht nutzt. Bei ruhigem Monitor liefert das Portal kein zweites Bild,
      # dann haengt die Freigabe bis zum Timeout (~45 s). Groesse 0 ueberspringt das Thumbnail.
      vesktop = pkgs.vesktop.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          asar=$out/opt/Vesktop/resources/app.asar
          ${pkgs.asar}/bin/asar extract "$asar" "$TMPDIR/vesktop-app"
          substituteInPlace "$TMPDIR/vesktop-app/dist/js/main.js" \
            --replace-fail 'let r=vy?1920:176' 'let r=vy?0:176'
          ${pkgs.asar}/bin/asar pack "$TMPDIR/vesktop-app" "$asar"
        '';
      });
    in
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

          xdg.configFile."vesktop/settings.json".source = ../../dotfiles/vesktop/settings.json;

          xdg.configFile."vesktop/settings/settings.json" = {
            source = ../../dotfiles/vesktop/vencord-settings.json;
            force = true;
          };

          xdg.configFile."vesktop/settings/quickCss.css" = {
            source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.stateHome}/mywm/vesktop.css";
            force = true;
          };

          home.activation.seedGamingConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
