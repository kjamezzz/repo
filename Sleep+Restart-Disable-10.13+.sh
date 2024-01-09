#!/bin/zsh
## Purpose: To hide the restart and sleep buttons from the login window and Apple menu.

## Disable sleep from the Apple menu.
defaults write /Library/Preferences/com.apple.PowerManagement SystemPowerSettings -dict SleepDisabled -bool YES

## Hide restart and sleep buttons from the Login Window.
defaults write /Library/Preferences/com.apple.loginwindow.plist PowerOffDisabled true

exit 0
