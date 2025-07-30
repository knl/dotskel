{ config, lib, pkgs, ... }:

{
  config = {
    targets.darwin.defaults = {
      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network volumes (default: false).
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.dock" = {
        # hide and put it on right
        autohide = true;
        orientation = "right";
        # Don’t automatically rearrange Spaces based on most recent use
        "mru-spaces" = 0;
        # Don’t show Dashboard as a Space
        "dashboard-in-overlay" = true;
        # Make it small
        tilesize = 42;
      };
      # Disable Dashboard
      "com.apple.dashboard" = {
        "mcx-disabled" = true;
      };
      "Apple Global Domain" = {
        # Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs) (default: not set).
        AppleKeyboardUIMode = 3;
        # Always show scrollbars (default: WhenScrolling).
        AppleShowScrollBars = "Always";
        # Show all filename extensions in Finder (default: false).
        AppleShowAllExtensions = true;
        # Expand save panel (default: false).
        NSNavPanelExpandedStateForSaveMode = true;
        # Display ASCII control characters using caret notation in standard text views
        # Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
        NSTextShowsControlCharacters = true;
        # Disable smart quotes as they’re annoying when typing code
        NSAutomaticQuoteSubstitutionEnabled = false;
        # Disable smart dashes as they’re annoying when typing code
        NSAutomaticDashSubstitutionEnabled = false;
        # Disable automatic capitalization as it’s annoying when typing code
        NSAutomaticCapitalizationEnabled = false;
        # Disable automatic period substitution as it’s annoying when typing code
        NSAutomaticPeriodSubstitutionEnabled = false;
        # Disable auto-correct
        NSAutomaticSpellingCorrectionEnabled = false;
        # Disable “natural” (Lion-style) scrolling
        "com.apple.swipescrolldirection" = false;
        # Trackpad: enable tap to click for this user
        "com.apple.mouse.tapBehavior" = 1;
        # Trackpad: map tap with two fingers to secondary click
        "com.apple.trackpad.trackpadCornerClickBehavior" = 1;
        "com.apple.trackpad.enableSecondaryClick" = true;
        # Set language and text formats
        AppleLanguages = [ "en" ];
        AppleLocale = "en_CH";
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = true;
      };
      "com.apple.finder" = {
        # Display full POSIX path as Finder window title (default: false).
        _FXShowPosixPathInTitle = true;
        # Disable the warning when changing a file extension (default: true).
        FXEnableExtensionChangeWarning = false;
        # Show hidden files by default
        AppleShowAllFiles = true;
        # Show status bar
        ShowStatusBar = true;
        # Show path bar
        ShowPathbar = true;
        # Allow text selection in Quick Look
        QLEnableTextSelection = true;
      };
      "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
        # Trackpad: enable tap to click for this user
        Clicking = true;
        # Trackpad: map tap with two fingers to secondary click
        TrackpadCornerSecondaryClick = 1;
        TrackpadRightClick = true;
      };
      "com.apple.HIToolbox" = {
        AppleCurrentKeyboardLayoutInputSourceID = "com.apple.keylayout.ABC";
        AppleEnabledInputSources = [
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 252;
            "KeyboardLayout Name" = "ABC";
          }
          {
            "Bundle ID" = "com.apple.inputmethod.EmojiFunctionRowItem";
            InputSourceKind = "Non Keyboard Input Method";
          }
          {
            "Bundle ID" = "com.apple.PressAndHold";
            InputSourceKind = "Non Keyboard Input Method";
          }
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 19;
            "KeyboardLayout Name" = "Swiss German";
          }
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 19521;
            "KeyboardLayout Name" = "Serbian";
          }
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = -19521;
            "KeyboardLayout Name" = "Serbian-Latin";
          }
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = -1;
            "KeyboardLayout Name" = "Unicode Hex Input";
          }
        ];
        AppleSelectedInputSources = [
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 252;
            "KeyboardLayout Name" = "ABC";
          }
          {
            "Bundle ID" = "com.apple.inputmethod.EmojiFunctionRowItem";
            InputSourceKind = "Non Keyboard Input Method";
          }
          {
            "Bundle ID" = "com.apple.PressAndHold";
            InputSourceKind = "Non Keyboard Input Method";
          }
        ];
      };
    };
  };
}
