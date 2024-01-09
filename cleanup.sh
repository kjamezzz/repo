#!/bin/bash

DEPNotifyLogFile="/var/tmp/depnotify.log"
DEPNotifyPlist="/var/tmp/DEPNotify.plist"
JAMFBinary="/usr/local/jamf/bin/jamf"
JAMFHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
Logo="/usr/local/company/images/Icon.png"

logEvent () {
	## Echo passed events and write to the logfile
	LogsFile="/var/log/postenrollment.log"
	echo $1
	echo $(date "+%Y-%m-%d %H:%M:%S: ") ["PostEnrollment"] $1 >> $LogsFile
}

cleanUp () {
	## Clean up items no longer needed.
	echo "Status: Cleaning Up Post Enrollment Items" >> "$DEPNotifyLogFile"
	rm /Library/LaunchAgents/edu.cuit.columbia.startpostenrollmentscript.plist
	rm /usr/local/company/startPostEnrollment.sh
  rm "$DEPNotifyPlist"
	logEvent "Cleaning up items."
}
cleanUp

disableAutoLogin () {
  ## Disable auto login.
  rm /etc/kcpassword
	defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser
	defaults write /Library/Preferences/.GlobalPreferences com.apple.userspref.DisableAutoLogin -bool true
	killall DEPNotify
}
disableAutoLogin

displayCompleteNotification () {
	## Prompt post enrollment has completed and restart once they press the Restart button.
	"$JAMFHelper" -windowType utility -icon "$Logo" -title "Post Enrollment Completed" -description "Post enrollment has completed. Please restart the computer." -button1 "OK"
	logEvent "Post Enrollement Completed."
}
displayCompleteNotification

exit 0
