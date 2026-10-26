{ ... }:

{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      programs.steam = {
        enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
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
          '';
        };
    };
}
