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

      programs.fish.enable = true;

      time.timeZone = "Europe/Berlin";

      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = builtins.listToAttrs (
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

      # Helium uses Chromium's Linux policy directory. Keep the extensions
      # installed for every Helium profile while still letting them receive
      # updates from the Chrome Web Store (proxied anonymously by Helium).
      environment.etc."chromium/policies/managed/helium-extensions.json".text = builtins.toJSON {
        ExtensionInstallForcelist = map (id: "${id};https://clients2.google.com/service/update2/crx") [
          "koficphcoicoimglkjglnkihljdeggpm" # Defaults for YouTube
          "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
          "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
          "nngceckbapebfimnlniiiahkandclblb" # Bitwarden Password Manager
          "omkfmpieigblcllmkgbflkikinpkodlk" # enhanced-h264ify
        ];
      };

      users.users.chris = {
        isNormalUser = true;

        extraGroups = [
          "wheel"
          "networkmanager"
        ];

        shell = pkgs.fish;

        hashedPasswordFile = "/persist/passwords/chris";
      };
    };
}
