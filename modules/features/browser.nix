{ config, ... }:

{
  flake.modules.nixos.browser = {
    home-manager.sharedModules = [ config.flake.modules.homeManager.browser ];

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
        "mdjildafknihdffpkfmmpnpoiajfjnjd" # Consent-O-Matic
        "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for YouTube
        "ndpmhjnlfkgfalaieeneneenijondgag" # YouTube Anti Translate
        "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
      ];
    };
  };

  flake.modules.homeManager.browser =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.local.helium ];

      xdg.mimeApps = {
        enable = true;

        defaultApplications = {
          "text/html" = [ "helium.desktop" ];
          "x-scheme-handler/http" = [ "helium.desktop" ];
          "x-scheme-handler/https" = [ "helium.desktop" ];
        };
      };
    };
}
