{ config, lib, pkgs, ... }:

{
  config = {
    programs.firefox = {
      enable = true;
      # Firefox is installed system-wide in /Applications (IT-managed);
      # home-manager only manages the profile.
      package = null;

      # Firefox downloads/updates these from AMO itself; nix fetches nothing.
      # Applied via macOS defaults (org.mozilla.firefox). Okta is IT-managed.
      # normal_installed: auto-installs, can be disabled but not removed in
      # about:addons; drop an entry here to make it removable again.
      #
      # Entries are <extension ID> = <AMO slug>. To add an extension:
      #   slug: from its AMO page URL (addons.mozilla.org/…/addon/<slug>/)
      #   id:   curl -s https://addons.mozilla.org/api/v5/addons/addon/<slug>/ | jq -r .guid
      # The ID must match the XPI manifest exactly or Firefox silently
      # rejects the install (errors show up in about:policies).
      policies.ExtensionSettings =
        lib.mapAttrs
          (_: slug: {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
          })
          {
            "uBlock0@raymondhill.net" = "ublock-origin";
            "jid1-ZAdIEUB7XOzOJw@jetpack" = "duckduckgo-for-firefox";
            "jid1-93WyvpgvxzGATw@jetpack" = "to-google-translate";
            "gdpr@cavi.au.dk" = "consent-o-matic";
            "leechblockng@proginosko.com" = "leechblock-ng";
            "jid0-bnmfwWw2w2w4e4edvcdDbnMhdVg@jetpack" = "tab-reloader";
            "tab-stash@condordes.net" = "tab-stash";
            "@ublacklist" = "ublacklist";
            "tridactyl.vim@cmcaine.co.uk" = "tridactyl-vim";
            "{8147ec6e-cedf-498d-9edc-571451b89a9f}" = "medium-unlimited-read-for-free";
            "copy-selected-tabs-to-clipboard@piro.sakura.ne.jp" = "copy-selected-tabs-to-clipboar";
            "ghosttext@bfred.it" = "ghosttext";
            "tst_colorize_tabs@emvaized.com" = "tst-colorize-tabs";
            "pinboard-plus@lsproc.com" = "pinboard-plus";
            "{07c6b8e1-94f7-4bbf-8e91-26c0a8992ab5}" = "promnesia";
          };
      profiles.default = {
        # Reuse the pre-existing profile so history/logins/extensions stay.
        path = "ad9aicjy.default-release";
        isDefault = true;

        search = {
          force = true;
          default = "ddg";
        };

        userChrome = ../../configs/firefox/userChrome.css;

        settings = {
          # UI & tabs
          "browser.uidensity" = 1; # compact density
          "browser.compactmode.show" = true;
          "browser.ctrlTab.sortByRecentlyUsed" = true;
          "browser.tabs.inTitlebar" = 0;
          "browser.tabs.groups.smart.userEnabled" = false;
          "sidebar.revamp" = true;
          "sidebar.verticalTabs" = true;
          "sidebar.position_start" = false; # sidebar on the right
          "sidebar.main.tools" = "history,tridactyl.vim@cmcaine.co.uk";
          "browser.toolbars.bookmarks.visibility" = "always";
          "browser.toolbars.bookmarks.showOtherBookmarks" = false;
          "browser.newtabpage.enabled" = false;
          "browser.newtabpage.activity-stream.showSearch" = false;
          "browser.sessionstore.warnOnQuit" = true;
          "accessibility.typeaheadfind.flashBar" = 0;
          "browser.ml.linkPreview.enabled" = false;
          # Required for userChrome.css to be picked up.
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

          # Privacy
          "signon.rememberSignons" = false;
          "privacy.donottrackheader.enabled" = true;
          "privacy.userContext.enabled" = true;
          "privacy.userContext.ui.enabled" = true;
          "privacy.clearOnShutdown_v2.formdata" = true;
          "browser.search.suggest.enabled" = false;
          "browser.urlbar.suggest.searches" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
          "browser.tabs.crashReporting.sendReport" = false;
          "app.shield.optoutstudies.enabled" = false;
          "network.dns.disablePrefetch" = true;
          "network.prefetch-next" = false;
          "network.trr.mode" = 5; # DoH off

          # Misc
          "intl.accept_languages" = "en-gb,en,de-ch";
          "intl.regional_prefs.use_os_locales" = true;
          "layout.spellcheckDefault" = 0;
          "devtools.webconsole.timestampMessages" = true;
          "devtools.webconsole.input.eagerEvaluation" = false;
        };
      };
    };
  };
}
