#!/bin/bash

backup_drive=$(tmutil destinationinfo | sed -rn 's/(Name +\: )//p')

echo "Continuing this script will make two changes to your computer:

1. The job that mounts your Time Machine disk, runs Time Machine, and then unmounts your Time Machine disk at a specific hour will be unscheduled and its plist removed.
2. Your Time Machine disk will again automatically mount when connected.

Time Machine disk: $backup_drive

Do you wish to continue? (y/n)"

read wish_to_continue

if [ "$wish_to_continue" != "y" ];
then
	echo "Exiting. No changes have been made."
	exit;
fi

drive_info=$(diskutil info "$backup_drive" 2>&1 > /dev/null)

if [[ $drive_info = "Could not find disk: $backup_drive" ]];
	then
	echo "Time Machine disk \"$backup_drive\" is not connected. 
Please connect \"$backup_drive\" and try again. 
Exiting. No changes have been made."
	exit
fi

# Unschedule launchd job.
# Remove plist
launch_agents_directory="$HOME/Library/LaunchAgents"
plist_name="com.jackwellborn.nightlytimemachine.plist"
plist="$launch_agents_directory/$plist_name"
if [ -f  "$plist" ];
then
	if [[ -n $(launchctl list | grep "com.jackwellborn.nightlytimemachine") ]];
	then
		launchctl unload "$plist"
		echo "Nightly Time Machine job has been unscheduled."
	else 
		echo "There is no Nightly Time Machine job to unschedule."
	fi
	rm "$plist"
	echo "Nightly Time Machine plist has been removed."
else
	echo "No Nightly Time Machine plist was found."
fi


# Remove Time Machine Disk to fstab.
echo "Configuring mounting behavior requires an admin password."
backup_uuid=$(diskutil info "$backup_drive" | sed -rn "s/ +Volume UUID\: +//p")
backup_type=$(diskutil info "$backup_drive" | sed -rn "s/ +Type \(Bundle\)\: +//p")

fstab_entry="UUID=$backup_uuid none $backup_type rw,noauto # $backup_drive"

fstab="/etc/fstab"
if [ ! -f "$fstab" ]
then
	echo "No fstab file not found. Exiting..."
	exit
fi

if [[ ! -z $(sudo grep "^$fstab_entry" "$fstab") ]]
then 
	sudo sed -i.'' "/$fstab_entry/d" "$fstab"
	echo "Time Machine disk \"$backup_drive\" has been configured to automatically mount when connected."
	backup_is_mounted=$(diskutil info "$backup_drive" | sed -rn "s/ +Mounted\: +//p")
	if [ "$backup_is_mounted" == "No" ];
	then
		echo "Would you like to mount \"$backup_drive\" now? (y/n)"
		read should_unmount
		if [ "$should_unmount" == "y" ];
		then
			unmount_err=$(diskutil mount "$backup_drive" 2>&1 > /dev/null)
			if [ "$?" -ne 0 ];
			then
				echo "\"$backup_drive\" could not be mounted at the moment and needs to be mounted manually."
			else
				echo "\"$backup_drive\" has been mounted."
			fi
		fi
	else
		echo "Unable to locate fstab configuration for Time Machine disk \"$backup_drive\""
	fi
fi

