# 
# Mac OS X setup
#
# The sudoers user is toor. Other users are knl and kne
#

# Install QLStephen from https://github.com/whomwah/qlstephen/downloads

defaults write com.apple.finder QLEnableTextSelection -bool true

pwpolicy -n /Local/Default -setglobalpolicy "minChars=8 requiresAlpha=1 requiresNumeric=1 maxMinutesUntilChangePassword=129600 usingHistory=8"
defaults write com.apple.loginwindow PasswordExpirationDays 10

# enable debug menu on Disk Utility
defaults write com.apple.DiskUtility DUDebugMenuEnabled 1

# use secure vm:
sudo defaults write /Library/Preferences/com.apple.virtualMemory DisableEncryptedSwap -boolean no

# use no virtual memory (vm):
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist
sudo rm /private/var/vm/swapfile*

# no bonjour multicast advertisments:
sudo defaults write /System/Library/LaunchDaemons/com.apple.mDNSResponder ProgramArguments -array-add "-NoMulticastAdvertisements"

# SSD related tweaks
sudo tmutil disablelocal
sudo pmset -a hibernatemode 0
sudo rm /var/vm/sleepimage

cat <<EOLN |sudo tee /Library/LaunchDaemons/net.soba143.knl.noatime.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
        "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>com.nullvision.noatime</string>
        <key>ProgramArguments</key>
        <array>
            <string>mount</string>
            <string>-vuwo</string>
            <string>noatime</string>
            <string>/</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
    </dict>
</plist>
EOLN
sudo chown root:wheel /Library/LaunchDaemons/net.soba143.knl.noatime.plist

# Mount key holding disks and setup paths
cat <<EOLN |sudo tee /etc/fstab
UUID=8E32BE7D-5E97-3E96-8C4F-B7992899BEBA /Users/kne/.securedisk hfs ro,auto,noatime,-u=kne,-m=700 0 0
UUID=7500C585-2FAD-3B22-A118-12395AB44B68 /Users/knl/.securedisk hfs ro,auto,noatime,-u=knl,-m=700 0 0
LABEL=REST none msdos rw,noauto,noatime 0 0
EOLN

sudo -u knl mkdir /Users/knl/.securedisk

sudo -u kne mkdir /Users/kne/.securedisk
sudo -u kne ln -sf /Users/kne/.securedisk/.ssh/id_rsa /Users/kne/.ssh/id_rsa
sudo -u kne ssh-keygen -y -f /Users/kne/.ssh/id_rsa |sudo -u kne tee /Users/kne/.ssh/id_rsa.pub
sudo -u kne ln -s /Users/kne/.securedisk/.gnupg/secring.gpg /Users/kne/.gnupg/secring.gpg
sudo -u kne ln -s /Users/kne/.securedisk/.gnupg/pubring.gpg /Users/kne/.gnupg/pubring.gpg

#!/bin/bash

# Via https://raw.github.com/mathiasbynens/dotfiles/master/.osx

# Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs) (default: not set).
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Enable subpixel font rendering on non-Apple LCDs (default: not set).
defaults write NSGlobalDomain AppleFontSmoothing -int 2

# Enable the 2D Dock (default: false).
# defaults write com.apple.dock no-glass -bool true

# Automatically hide and show the Dock (default: false).
defaults write com.apple.dock autohide -bool true

# Make Dock icons of hidden applications translucent (default: false).
# defaults write com.apple.dock showhidden -bool true

# Disable menu bar transparency (default: true).
# defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false

# Show remaining battery time, hide percentage.
# defaults write com.apple.menuextra.battery ShowPercent -string "NO"
# defaults write com.apple.menuextra.battery ShowTime -string "YES"

# Always show scrollbars (default: WhenScrolling).
# defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Allow quitting Finder via ⌘ + Q (will also hide desktop icons) (default: false).
# defaults write com.apple.finder QuitMenuItem -bool true

# Show all filename extensions in Finder (default: false).
# defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Expand save panel (default: false).
# defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# Expand print panel (default: false).
# defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# Disable 'Are you sure you want to open this application?' (default: true).
# defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable shadow in screenshots (default: false).
defaults write com.apple.screencapture disable-shadow -bool true

# Enable highlight hover effect for the grid view of a stack (default: false).
# defaults write com.apple.dock mouse-over-hilte-stack -bool true

# Enable spring loading for all Dock items (default: false).
# defaults write enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock (default: false).
defaults write com.apple.dock show-process-indicators -bool true

# Don’t animate opening applications from the Dock (default: true).
# defaults write com.apple.dock launchanim -bool false

# Disable press-and-hold for keys in favor of key repeat (default: true).
# defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate (default: 60).
# defaults write NSGlobalDomain KeyRepeat -int 0

# Disable auto-correct (default: true).
# defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable window animations (default: true).
# defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Enable AirDrop over Ethernet and on unsupported Macs running Lion (default: false).
# defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Disable disk image verification (default: false).
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Automatically open a new Finder window when a volume is mounted (default: false).
# defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
# defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true

# Display full POSIX path as Finder window title (default: false).
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Increase window resize speed for Cocoa applications (default: not set).
# defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Avoid creating .DS_Store files on network volumes (default: false).
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Disable the warning when changing a file extension (default: true).
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show item info below desktop icons (default false).
# /usr/libexec/PlistBuddy \
#   -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" \
#   ~/Library/Preferences/com.apple.finder.plist

# Disable the warning before emptying the Trash (default: true).
# defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Empty Trash securely (default: false).
# defaults write com.apple.finder EmptyTrashSecurely -bool true

# Require password immediately after sleep or screen saver begins.
# defaults write com.apple.screensaver askForPassword -int 1
# defaults write com.apple.screensaver askForPasswordDelay -int 0

# Enable Trackpad tap to click (default: false).
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad \
  Clicking -bool true

# Map bottom right Trackpad corner to right-click.
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad \
#   TrackpadCornerSecondaryClick -int 2
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad \
#   TrackpadRightClick -bool true

# Disable Safari’s thumbnail cache for History and Top Sites
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

# Enable Safari’s debug menu (default: false).
# defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Remove useless icons from Safari’s bookmarks bar
# defaults write com.apple.Safari ProxiesInBookmarksBar "()"

# Only use UTF-8 in Terminal.app.
# defaults write com.apple.terminal StringEncodings -array 4

# Disable the Ping sidebar in iTunes (default: false).
defaults write com.apple.iTunes disablePingSidebar -bool true

# Disable all the other Ping stuff in iTunes (default: false).
defaults write com.apple.iTunes disablePing -bool true

# Disable send and reply animations in Mail.app (default: false).
# defaults write com.apple.Mail DisableReplyAnimations -bool true
# defaults write com.apple.Mail DisableSendAnimations -bool true

# Disable Resume system-wide (default: true).
# defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# Enable Dashboard dev mode for keeping widgets on the desktop (default: false).
# defaults write com.apple.dashboard devmode -bool true

# Reset Launchpad.
# [ -e ~/Library/Application\ Support/Dock/*.db ] \
#  && rm ~/Library/Application\ Support/Dock/*.db

# Show the ~/Library folder (default: hidden).
# chflags nohidden ~/Library

# Disable local Time Machine backups (default: enabled).
# hash tmutil &> /dev/null && sudo tmutil disablelocal

# Remove Dropbox’s green checkmark icons in Finder.app.
# file=/Applications/Dropbox.app/Contents/Resources/check.icns
# [ -e "$file" ] && mv -f "$file" "$file.bak"
# unset file

# Fix for the ancient UTF-8 bug in QuickLook (http://mths.be/bbo).
# Causes problems when saving files in Adobe Illustrator CS5.
# echo "0x08000100:0" > ~/.CFUserTextEncoding

# Kill affected applications
for app in Safari Finder Dock Mail SystemUIServer; do
  killall "$app" >/dev/null 2>&1;
done


killall Dock