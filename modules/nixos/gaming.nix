{ ... }:

{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      programs.steam.enable = true;

      hardware.graphics.enable32Bit = true;
      services.pipewire.alsa.support32Bit = true;

      home-manager.users.chris = {
        home.packages = with pkgs; [
          heroic
          vesktop
        ];

        xdg.configFile."vesktop/settings.json".source =
          ../../dotfiles/vesktop/settings.json;
      };
    };
}
