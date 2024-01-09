#!/bin/bash

## Third party binaries used in this script.
JAMFBinary="/usr/local/jamf/bin/jamf"
JAMFHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
DEPNotify="/usr/local/company/bin/DEPNotify.app/Contents/MacOS/DEPNotify"
Logo="/usr/local/company/images/Icon.png"
ConfigurationInfo="/private/var/root/Library/Preferences/com.company.computerinfo"

########################################
##																		##
## 				Initial Configuration				##
##									  								##
########################################

standardizeLocalAdminAccount () {
	## Cases where the non DEP enrollment workflow is being used, the local admin account is created manually.
	$JAMFBinary policy -event StandardizeLocalAdmin
}
standardizeLocalAdminAccount

setDEPNotifySettings () {
	DEPNotifyLogFile="/var/tmp/depnotify.log"
	$JAMFBinary policy -event DEPNotify110
	echo "Command: WindowStyle: NotMovable" >> "$DEPNotifyLogFile"
	echo "Command: Image: $Logo" >> "$DEPNotifyLogFile"
	echo "Command: MainTitle: Standard Configuration" >> "$DEPNotifyLogFile"
	echo "Command: MainText:  Please click on the SET button below to set the computer name and the technician's " >> "$DEPNotifyLogFile"
	echo "Status: Waiting for computer name to be set." >> "$DEPNotifyLogFile"
	defaults write menu.nomad.DEPNotify PathToPlistFile /var/tmp/
    defaults write menu.nomad.DEPNotify RegisterMainTitle "Information"
    defaults write menu.nomad.DEPNotify RegistrationButtonLabel Assign
    defaults write menu.nomad.DEPNotify UITextFieldUpperLabel "Support Technican"
    defaults write menu.nomad.DEPNotify UITextFieldUpperPlaceholder "xx9999"
    defaults write menu.nomad.DEPNotify UITextFieldLowerLabel "Computer_Name"
    defaults write menu.nomad.DEPNotify UITextFieldLowerPlaceholder "XXX-XX9999-1"
    defaults write menu.nomad.DEPNotify UIPopUpMenuUpperLabel 'Configuration'
    defaults write menu.nomad.DEPNotify UIPopUpMenuUpper -array 'test'
}
setDEPNotifySettings

preventSleep () {
	## Prevent computer from going to sleep.
	/usr/bin/caffeinate -imd &
}
preventSleep

createManagementDir () {
	## Repositories used.
	ManagementDir="/usr/local/company/"
	## Reapply permissions to management folder.
	chmod -R 755 "$ManagementDir"
}
createManagementDir

logEvent () {
	## Echo passed events and write to the logfile
	LogsFile="/var/log/postenrollment.log"
	echo $1
	echo $(date "+%Y-%m-%d %H:%M:%S: ") ["PostEnrollment"] $1 >> $LogsFile
}

startDEPNotify () {
	/usr/local/company/bin/DEPNotify.app/Contents/MacOS/DEPNotify -fullScreen &
}
startDEPNotify

getUserInformation () {
    ## User information.
    DEPNotifyPlist="/var/tmp/DEPNotify.plist"
    echo "Command: ContinueButtonRegister: Set Name" >> "$DEPNotifyLogFile"
    ## Wait for user input.
    while : ; do
        [[ -f $DEPNotifyPlist ]] && break
        sleep 1
    done
}
getUserInformation

setComputerName () {
	## Prompt technician to enter in computer name which will be used for setting the computer name, local hostname, and hostname.
	EnteredComputerName=$(defaults read /var/tmp/DEPNotify.plist "Computer_Name")
	logEvent "Setting computer name for local host name, hostname, and computer name which will be used for binding purposes."
}
setComputerName

outputChosenConfiguration () {
	##Output choice the technician has chosen.
	OutputChoice=$(defaults read /var/tmp/DEPNotify.plist "Configuration")
}
outputChosenConfiguration

setDEPNotifySecondarySettings () {
	TotalDeterminates="60"
	echo "Command: WindowStyle: NotMovable" >> "$DEPNotifyLogFile"
	echo "Command: Image: $Logo" >> "$DEPNotifyLogFile"
	echo "Command: MainTitle: Standard Configuration" >> "$DEPNotifyLogFile"
	echo "Command: MainText: Your Mac is currently being configured with core applications and standardized settings.  Please allow 30-45 minutes to allow the configuration to complete." >> "$DEPNotifyLogFile"
	echo "Command: Determinate: $TotalDeterminates"  >> "$DEPNotifyLogFile"
}
setDEPNotifySecondarySettings

completeInitialPostEnrollment () {
	## Create complete receipt file for initial post enrollment stage.
	echo "Status: Performing an initial inventory update and submitting to Jamf Pro" >> "$DEPNotifyLogFile"
	touch /usr/local/company/.DEP-Installs-Completed
	$JAMFBinary recon
	logEvent "Creating receipt file and updating inventory."
}
completeInitialPostEnrollment

########################################
##									  ##
## 		Configuration Versioning	  ##
##									  ##
########################################

if [[ "$OutputChoice" =~ "company-config-Lab" ]]; then
	ConfigurationVersion="company-configLab-2006"
	ConfigurationName="DEP-company-configLab"
fi


setConfigurationVersion () {
	## Configuration and versioning.
	echo "Status: Applying configuration name and version" >> "$DEPNotifyLogFile"
	## Location of plist file to store configuration information.
	PLIST_FILE="/private/var/root/Library/Preferences/com.company.computerinfo"
	## Set configuration version
	logEvent "DEP Configuration Version is $ConfigurationVersion"
	/usr/bin/defaults write "$1/$PLIST_FILE" ImageVersion "$ConfigurationVersion"
	logEvent "DEP Configuration is $ConfigurationName"
	/usr/bin/defaults write "$1/$PLIST_FILE" ImageConfiguration "$ConfigurationName"
	## Run an inventory update to update extension attributes.
	$JAMFBinary recon
}
setConfigurationVersion

######################################
##																	##
##			Standard Configuration			##
##																	##
######################################

nameComputer () {
	## Set computer with the name provided.
	if [ $EnteredComputerName == 2 ]
		then
		exit 0
		echo "Status: Technician did not provide a valid name." >> "$DEPNotifyLogFile"
	else
		## Change computer name, local hostname, and hostname with user provided input.
		echo "Status: Applying computer name." >> "$DEPNotifyLogFile"
		/usr/sbin/scutil --set ComputerName "$EnteredComputerName"
		/usr/sbin/scutil --set HostName "$EnteredComputerName"
		/usr/sbin/scutil --set LocalHostName "$EnteredComputerName"
	fi
		logEvent "Setting computer name."
}
nameComputer

if [[ "$OutputChoice" != "Company" ]]; then
installStandardApps () {
	## Install all standard apps.
	StandardAppList="AdobeAcrobatPro2017
	Bomgar
	BBEdit13
	desktoppr
	EdGCM
	Firefox
	GeoMapApp
	GoogleChrome
	GoogleEarthPro
	HPPrinterDrivers
	installDockUtil
	JavaForOSX
	KeyServer
	LabStats
  MalwareBytes
	Mathematica
	MatLab
	MSOffice2019
	NoMAD
	NoMADLogin
	QGIS
	RandRStudio
	SplashtopStreamer
  StataSE
	TeXworks
	VLC
	XcodeCommandLineTools
  XQuartz
	Zotero"

for i in $StandardAppList; do
	echo "Status: Installing Standard Applications." >> "$DEPNotifyLogFile"
	$JAMFBinary policy -event $i
	logEvent "Installing $i."
done
}
installStandardApps


########################################
##									  								##
## 		Build Configuration 		  			##
##									  								##
########################################

if [[ "$OutputChoice" =~ "Lab" ]]; then
installLabApps () {
	## Install all Lab apps.
	## Temporarily removed - autologout20min.
	LabAppList="installLoginDesktopAdmin
	mapPawPrintPrinters"

for l in $LabAppList; do
	echo "Status: Installing Standard Lab Applications and Settings." >> "$DEPNotifyLogFile"
	$JAMFBinary policy -event $l
	logEvent "Installing $l."
done
}
installLabApps
fi

if [[ "$OutputChoice" =~ "Podium" ]]; then
installPodiumApps () {
	## Install all Podium apps.
	PodiumAppList="autologout90min
	CourseWorksShortcut
	createClassroomAccount
	GeekTool
	installLoginDesktopAdmin
	installToggleMirroring
	LogoutApp
	LionMailShortcut
	mapPawPrintPrinters
	PollEverywhere"

for k in $PodiumAppList; do
	echo "Status: Installing Standard Podium Applications and Settings." >> "$DEPNotifyLogFile"
	$JAMFBinary policy -event $k
	logEvent "Installing $k."
done
}
installPodiumApps
fi

if [[ "$OutputChoice" =~ "config" ]]; then
installconfigApps () {
	## Install all config apps.
	## Install all config apps.
	configLabAppList="AdobeCC2020
	AnalySeries
	Celtx
	ENVI
	Fugu
	Java8JRE
	JWatcher
	OceanDataView
	PlateTectonics
	Shape
	SplashtopStreamer
	StellaPro"

for i in $configLabAppList; do
	echo "Status: Installing config Applications." >> "$DEPNotifyLogFile"
	$JAMFBinary policy -event $i
	logEvent "Installing $i."
done
}
installconfigApps
fi

######################
##									##
##  Post Enrollment	##
##									##
######################

applyPostConfigurationSettings () {
	PostConfigurationList="applyUserTemplate
	SetDNSSearchDomains
	SlackNotifications
	PostEnrollmentCleanup"

for p in $PostConfigurationList; do
	echo "Status: Applying Post Configuration Settings: $p." >> "$DEPNotifyLogFile"
	$JAMFBinary policy -event $p
	logEvent "Installing $p."
done
}
applyPostConfigurationSettings

exit 0
