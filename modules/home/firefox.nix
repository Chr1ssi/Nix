{ inputs, ... }:

{
  flake.modules.homeManager.firefox = { pkgs, ... }: {
    programs.firefox = {
      enable = true;

      profiles.default = {
        id = 0;
        isDefault = true;

        extensions.packages =
          with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
            ublock-origin
            darkreader
            bitwarden
          ];

        settings = {
          # ─────────────────────────────────────────────
          # Appearance
          # ─────────────────────────────────────────────

          # Prefer dark mode in Firefox and on websites
          "ui.systemUsesDarkTheme" = 1;
          "browser.theme.content-theme" = 0;
          "browser.theme.toolbar-theme" = 0;
          "layout.css.prefers-color-scheme.content-override" = 0;

          # ─────────────────────────────────────────────
          # UI / Firefox Features
          # ─────────────────────────────────────────────

          "browser.aboutConfig.showWarning" = false;

          # Sponsored / recommendation content
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.default.sites" = "";

          "browser.discovery.enabled" = false;
          "browser.shopping.experience2023.enabled" = false;

          # URL bar recommendations
          "browser.urlbar.quicksuggest.enabled" = false;
          "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          "browser.urlbar.trending.featureGate" = false;
          "browser.urlbar.addons.featureGate" = false;
          "browser.urlbar.fakespot.featureGate" = false;
          "browser.urlbar.pocket.featureGate" = false;
          "browser.urlbar.weather.featureGate" = false;

          # ─────────────────────────────────────────────
          # Telemetry / Experiments
          # ─────────────────────────────────────────────

          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;

          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;

          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;

          "app.shield.optoutstudies.enabled" = false;
          "app.normandy.enabled" = false;

          "browser.ping-centre.telemetry" = false;
          "browser.messaging-system.whatsNewPanel.enabled" = false;

          # ─────────────────────────────────────────────
          # Network privacy
          # ─────────────────────────────────────────────

          "network.prefetch-next" = false;
          "network.dns.disablePrefetch" = true;
          "network.dns.disablePrefetchFromHTTPS" = true;

          "network.predictor.enabled" = false;
          "network.predictor.enable-prefetch" = false;

          "network.http.speculative-parallel-limit" = 0;
          "browser.places.speculativeConnect.enabled" = false;
          "browser.urlbar.speculativeConnect.enabled" = false;

          # Don't send full path/query when crossing origins
          "network.http.referer.XOriginTrimmingPolicy" = 2;

          # ─────────────────────────────────────────────
          # Security
          # ─────────────────────────────────────────────

          "dom.security.https_only_mode" = true;
          "dom.security.https_only_mode_send_http_background_request" = false;

          "security.tls.enable_0rtt_data" = false;
          "security.ssl.treat_unsafe_negotiation_as_broken" = true;

          # Show xn-- domains explicitly instead of potentially deceptive
          # Unicode domain names.
          "network.IDN_show_punycode" = true;

          # Disable JavaScript inside PDFs
          "pdfjs.enableScripting" = false;

          # ─────────────────────────────────────────────
          # Tracking protection
          # ─────────────────────────────────────────────

          "browser.contentblocking.category" = "strict";

          # Firefox Containers
          "privacy.userContext.enabled" = true;
          "privacy.userContext.ui.enabled" = true;

          # ─────────────────────────────────────────────
          # Search / Forms
          # ─────────────────────────────────────────────

          # Don't send typed searches while typing
          "browser.search.suggest.enabled" = false;
          "browser.urlbar.suggest.searches" = false;

          # Disable Firefox form history/autofill
          "browser.formfill.enable" = false;

          # ─────────────────────────────────────────────
          # Downloads
          # ─────────────────────────────────────────────

          "browser.download.start_downloads_in_tmp_dir" = true;
          "browser.helperApps.deleteTempFileOnExit" = true;

          "browser.download.manager.addToRecentDocs" = false;
          "browser.download.always_ask_before_handling_new_types" = true;

          # ─────────────────────────────────────────────
          # Extensions
          # ─────────────────────────────────────────────

          # Automatically allow extensions installed declaratively by
          # Home Manager.
          "extensions.autoDisableScopes" = 0;

          # Keep Mozilla's extension blocklist enabled.
          "extensions.blocklist.enabled" = true;
          "extensions.quarantinedDomains.enabled" = true;
        };
      };
    };
  };
}
