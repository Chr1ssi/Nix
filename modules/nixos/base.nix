{ ... }:

{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      networking.networkmanager.enable = true;

      services.openssh = {
        enable = true;
        openFirewall = true;
      };

      time.timeZone = "Europe/Berlin";

      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings =
        builtins.listToAttrs (
          map
            (name: {
              inherit name;
              value = "de_DE.UTF-8";
            })
            [
              "LC_ADDRESS"
              "LC_IDENTIFICATION"
              "LC_MEASUREMENT"
              "LC_MONETARY"
              "LC_NAME"
              "LC_NUMERIC"
              "LC_PAPER"
              "LC_TELEPHONE"
              "LC_TIME"
            ]
        );

      console.keyMap = "de";
      services.xserver.xkb.layout = "de";

      environment.systemPackages = with pkgs; [
        curl
        wget
        unzip
      ];

      users.users.chris = {
        isNormalUser = true;

        extraGroups = [
          "wheel"
          "networkmanager"
        ];
      };
    };
}
