#!/usr/bin/env bash

# Title: Driver for patching the Apple Remote Control Daemon.
# Description: This is a simple command line driver for patching the remote control
#  daemon.  The actual patching is done by the python script (patch_bytes.py).
#
# Author: Farhan Ahmad <farhan@thebitguru.com>
# Website: http://www.thebitguru.com/projects/iTunesPatch
#
# Revision history:
#  2010-11-18, fa: Created
#  2010-11-28, fa: Updated to use patch_bytes.py script instead of the previously
#     used bsdiff/bspatch method.
#  2011-08-18, fa: Added fix submitted by Michael Winestock to account for spaces
#     in the directory name.
#  2011-09-03, fa: Added Michael's contact info 
#     Michael Winestock  http://www.linkedin.com/pub/michael-winestock/18/579/972
#
# Technical notes:
#   Create a backup of the original file (cp rcd rcd_original_os).
#   Comment out (--) the iTunes launch lines in rcd.

VERSION=0.8   # Version of the script.

rcd_path=/System/Library/CoreServices/rcd.app/Contents/MacOS

# MD5 sum of the current rcd
calculated_rcd_md5=`md5 -q $rcd_path/rcd`

if [[ `id -u` == "0" ]]; then
	echo " Confirmed that the script is running as root (uid `id -u`)."
fi

# Banner
echo
echo "-------------------------- Play Button iTunes Patch --------------------------"

# Make sure the script is running as root.
if [[ `id -u` != "0" ]]; then
	echo " This patch requires that you run it as root.  Trying: sudo $0"
	sudo "$0"
	exit
fi

# Print a banner and confirm that the user has root access.
if [[ "$1" != "--nobanner" ]]; then
	echo " This program will patch the Remote Control Daemon to prevent it from starting"
	echo " iTunes whenever you press the play button on the keyboard or an external"
	echo " remote control. This will only prevent iTunes from starting, all other"
	echo " functions (like play/pause while iTunes is _running_) will continue to work"
	echo " as before."
	echo ""
	echo " Also, this program will backup the original file in case if you would like"
	echo " to restore the original functionality."
	echo
	echo " This program comes with ABSOLUTELY NO WARRANTY; please see the included"
	echo " license file for details."
	echo
fi


# Check if the program has already been in patched, in which case, present the
# option to restore the original file.
confirm=1
backup_count=`find $rcd_path -type f -maxdepth 1 -name rcd_backup_\* | wc -l`
if [[ $backup_count -ne 0 ]]; then
	echo " Found an existing backup file. "
	echo -n " "
	find $rcd_path -type f -maxdepth 1 -name rcd_backup_\*
	echo
	echo -n "Would you like to undo the patch and restore the backed up file? (y/N) "
	read restore_from_backup
	restore_from_backup=`echo $restore_from_backup | tr '[:lower:]' '[:upper:]' | cut -b 1`
	if [[ "$restore_from_backup" != "Y" ]]; then
		echo "You can only restore since you have the file already patched. Aborting."
		echo
		exit
	fi

	# Restore from the backup, use the first backup file.
	echo
	backup_file=`find $rcd_path -type f -maxdepth 1 -name rcd_backup_\* | head -1`
	killall rcd 2> /dev/null            # Kill any existing processes
	mv -f $backup_file $rcd_path/rcd    # Restore the backup file.
	echo "Restore complete.  Your original functionality should be back.  To verify:"
	echo " 1. If iTunes is already running then quit it first."
	echo " 2. Press the play button on your keyboard."
	echo " 3. If iTunes started then the original file was successfully restored and "
	echo "    you should have the original functionality back."
	echo
	echo "For questions and/or comments please visit http://www.thebitguru.com/projects/iTunesPatch"
	exit
fi

# === Otherwise, we are patching the original file for the first time.

# Get a final confirmation from the user.
echo
echo -n "Everything is ready. Would you like to create a backup and apply the patch? (y/N) "
read go_ahead
go_ahead=`echo $go_ahead | tr '[:lower:]' '[:upper:]' | cut -b 1`
if [[ "$go_ahead" != "Y" ]]; then
	echo "You must answer yes, aborting."
	echo
	exit
fi

# Everything is good, let's stop the process, backup existing version and then patch.
echo "Patching..."
killall rcd 2> /dev/null   # Stop any running processing.
echo " + Killed any running processes."
backup_filename="rcd_backup_${VERSION}_`date "+%Y%m%d%H%M.%S"`"
cp $rcd_path/rcd $rcd_path/$backup_filename
echo " + Backed up the existing file as $backup_filename"
echo " + Patching..."
cd "`dirname \"$0\"`"
./edit_rcd_bin.py $rcd_path/rcd
if [[ $? -eq 0 ]]; then
	echo " + Successfully patched the existing file."
	echo
	echo "Finished patching.  To verify: "
	echo " 1. If iTunes is already running then quit it first."
	echo " 2. Press the play button on your keyboard."
	echo " 3. If iTunes did not start then the patch was applied successfully."
	echo " 4. Enjoy."
	echo
	echo "Run this script again if you would like to restore the original functionality."
else
	echo " !!! Sorry, an unexpected error occurred while patching. Please email me all"
	echo "     of the above text and attach $rcd_path/rcd "
	echo "     for troubleshooting at farhan@thebitguru.com."
fi

echo
echo
echo "For questions and/or comments please visit http://www.thebitguru.com/projects/iTunesPatch"
