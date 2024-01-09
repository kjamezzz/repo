#!/bin/zsh

## LaunchAgent and Dock settings script Path
DockSettingsLaunchAgent="/Library/LaunchAgents/com.company.plist"
DockSettingsScript="/usr/local/columbia/scripts/StartDockSettings.sh"

createManagementFolder () {
	## Create managed scripts folder if it does not exist.
	if [[ ! -e "/usr/local/company/scripts" ]]; then
		mkdir -p /usr/local/company/scripts
	fi
}
createManagementFolder

createScript () {
	## Create DockUtil script locally on computer.
	ConfigurationName=$(defaults read /private/var/root/Library/Preferences/com.company.computerinfo ImageConfiguration)

	########################################

		  	 # DEP-CUH-Administrative #

	########################################

	if [[ "$ConfigurationName" == "DEP-CUH-Administrative" ]]; then

(
cat <<'EOD'
#!/bin/zsh

CurrentUser=$(stat -f%Su /dev/console)
DockUtil="/usr/local/bin/dockutil"
OSVersion=$(sw_vers | grep ProductVersion | awk '{ print $2 }')

if [[ -e /Users/"$CurrentUser"/.docksettings ]]; then

	echo "Already ran dock settings."

else

	sleep 5

	## Remove all dock items from current user's dock.
	$DockUtil --remove all "/Users/$CurrentUser"

	sleep 1

	## Add dock items to current user's dock.
	$DockUtil --add "/Applications/Microsoft Word.app" --no-restart "/Users/$CurrentUser"
	$DockUtil --add "/Applications/Microsoft Excel.app" --no-restart "/Users/$CurrentUser"
	$DockUtil --add "/Applications/Microsoft PowerPoint.app" --no-restart "/Users/$CurrentUser"
	$DockUtil --add "/Applications/VLC.app" --no-restart "/Users/$CurrentUser"
	$DockUtil --add "/Applications/Google Chrome.app" --no-restart "/Users/$CurrentUser"
	$DockUtil --add "/Applications/Safari.app" --no-restart "/Users/$CurrentUser"
	$DockUtil --add "/Applications/Adobe Acrobat Reader DC.app" --no-restart "/Users/$CurrentUser"
	$DockUtil --add "/Applications/Microsoft Teams.app" --no-restart "/Users/$CurrentUser"
	$DockUtil --add "/System/Applications/System Preferences.app" --no-restart "/Users/$CurrentUser"
	$DockUtil --add "/Applications/Cisco/Cisco AnyConnect Secure Mobility Client.app" --no-restart "/Users/$CurrentUser"
	$DockUtil --add "/Applications/Self Service.app" --no-restart "/Users/$CurrentUser"


  ## Create hidden file to avoid having to do a once per user frequency trigger which would need to be flushed if a computer gets reimaged.
  /usr/bin/touch /Users/"$CurrentUser"/.docksettings

fi

exit 0
EOD
) > "$DockSettingsScript"

	fi
}
createScript

createLaunchAgent () {
## Create LaunchAgent.
(
cat <<'EOD'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>edu.columbia.cuit.docksettings</string>
	<key>ProgramArguments</key>
	<array>
		<string>/usr/local/columbia/scripts/StartDockSettings.sh</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
EOD
) > "$DockSettingsLaunchAgent"
}
createLaunchAgent

applyPermissions () {
	## Ensure proper permissions for both files.
	chown root:wheel "$DockSettingsLaunchAgent"
	chmod 644 "$DockSettingsLaunchAgent"
	chown root:wheel "$DockSettingsScript"
	chmod +x "$DockSettingsScript"
}
applyPermissions

exit 0
