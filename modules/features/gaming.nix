{ inputs, ... }:

{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [ inputs.millennium.overlays.default ];

      programs.steam = {
        enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
        # Millennium patches the client to load themes (plain `pkgs.steam` to go back).
        # Proton runs its games on its Wayland driver, so they need no launch option and no X11 window.
        # A game that breaks with it takes `PROTON_ENABLE_WAYLAND=0 %command%`.
        package = pkgs.millennium-steam.override { extraEnv.PROTON_ENABLE_WAYLAND = "1"; };
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

          xdg.configFile."vesktop/settings.json".source = ../../dotfiles/vesktop/settings.json;

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
              ${lib.escapeShellArg "${config.xdg.configHome}/goverlay"}

            if [ ! -e ${lib.escapeShellArg "${config.xdg.configHome}/MangoHud/MangoHud.conf"} ]; then
              run install -m 644 \
                ${../../dotfiles/MangoHud/MangoHud.conf} \
                ${lib.escapeShellArg "${config.xdg.configHome}/MangoHud/MangoHud.conf"}
            fi
          '';
        };
    };
}
