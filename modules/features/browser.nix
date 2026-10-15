{ config, ... }:

let
  # Force-installed from addons.mozilla.org, updated by LibreWolf itself
  # (the counterpart to Chromium's ExtensionInstallForcelist).
  amoExtension = slug: {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
  };
in
{
  flake.modules.nixos.browser = {
    home-manager.sharedModules = [ config.flake.modules.homeManager.browser ];

    # Lets the logged-in user's Chromium reach the ROG SpeedNova mouse via
    # WebHID (the Keychron keyboard already gets uaccess from OpenRGB's rules).
    services.udev.extraRules = ''
      KERNEL=="hidraw*", ATTRS{idVendor}=="0b05", ATTRS{idProduct}=="1ad0", TAG+="uaccess"
    '';
  };

  flake.modules.homeManager.browser =
    { pkgs, ... }:
    {
      programs.librewolf = {
        enable = true;

        policies = {
          # LibreWolf's own policies.json disables EME; ours is merged on top.
          EncryptedMediaExtensions.Enabled = true;

          # uBlock Origin is already installed by LibreWolf's policies.json.
          ExtensionSettings = {
            "addon@darkreader.org" = amoExtension "darkreader";
            "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = amoExtension "return-youtube-dislikes";
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = amoExtension "bitwarden-password-manager";
            "{9a41dee2-b924-4161-a971-7fb35c053a4a}" = amoExtension "enhanced-h264ify";
            "gdpr@cavi.au.dk" = amoExtension "consent-o-matic";
            "sponsorBlocker@ajay.app" = amoExtension "sponsorblock";
            "jid1-MnnxcxisBPnSXQ@jetpack" = amoExtension "privacy-badger17";
            "youtube-anti-translate-mv3@namakeingo.co.uk" = amoExtension "youtube-anti-translate-mv3";
            # Stands in for "Defaults for YouTube", which has no Firefox build.
            "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}" = amoExtension "youtube-addon";
          };
        };

        profiles.default = {
          id = 0;
          isDefault = true;

          settings = {
            # Dark mode. RFP always reports a light color scheme to websites,
            # so use FPP with every RFP target except that one instead.
            "privacy.resistFingerprinting" = false;
            "privacy.fingerprintingProtection" = true;
            "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme";
            "ui.systemUsesDarkTheme" = 1;
            "browser.theme.content-theme" = 0;
            "browser.theme.toolbar-theme" = 0;
            "layout.css.prefers-color-scheme.content-override" = 0;

            # DRM (Widevine). LibreWolf also disables the plugin downloader
            # that fetches the Widevine CDM, and asks before every playback.
            "media.eme.enabled" = true;
            "media.gmp-widevinecdm.enabled" = true;
            "media.gmp-manager.updateEnabled" = true;
            "media.eme.require-app-approval" = false;

            # Stay signed in: keep cookies and site data on shutdown
            # (LibreWolf already keeps the history).
            "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;

            # Compact, clean UI; the styling is in userChrome.css.
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "widget.transparent-windows" = true;
            "browser.compactmode.show" = true;
            "browser.uidensity" = 1;
            "browser.toolbars.bookmarks.visibility" = "newtab";
            # The layout below is rewritten on every start; without this,
            # buttons missing from it would be added back each time (add-on
            # buttons then stay in the extensions menu).
            "browser.uiCustomization.autoAdd" = false;
            "browser.uiCustomization.state" = builtins.toJSON {
              placements = {
                nav-bar = [
                  "back-button"
                  "forward-button"
                  "stop-reload-button"
                  "urlbar-container"
                  "downloads-button"
                  "unified-extensions-button"
                ];
                TabsToolbar = [
                  "tabbrowser-tabs"
                  "new-tab-button"
                ];
                vertical-tabs = [ ];
                PersonalToolbar = [ "personal-bookmarks" ];
                toolbar-menubar = [ "menubar-items" ];
                widget-overflow-fixed-list = [ ];
                unified-extensions-area = [ ];
              };
              seen = [ ];
              dirtyAreaCache = [ ];
              # CustomizableUI's kVersion in LibreWolf 156; an older value
              # would run migrations that add buttons back.
              currentVersion = 26;
              newElementCount = 0;
            };
          };

          userChrome = ../../dotfiles/librewolf/userChrome.css;
        };
      };

      # Only for configuring / flashing the mouse and keyboard via WebHID.
      home.packages = [ pkgs.ungoogled-chromium ];

      xdg.mimeApps = {
        enable = true;

        defaultApplications = {
          "text/html" = [ "librewolf.desktop" ];
          "x-scheme-handler/http" = [ "librewolf.desktop" ];
          "x-scheme-handler/https" = [ "librewolf.desktop" ];
        };
      };
    };
}
