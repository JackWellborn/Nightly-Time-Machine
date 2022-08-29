#!/bin/bash

backup_drive=$(tmutil destinationinfo | sed -rn 's/(Name +\: )//p')

echo "Continuing this script will make three changes to your computer:

1. Script Editor will be added to the list of apps available in the Notification & Focus preference pane. 
2. A job will be scheduled at a specified hour to mount your Time Machine disk, run Time Machine, and then unmount your Time Machine disk.
3. Your Time Machine disk will no longer automatically mount when connected.

Time Machine disk: $backup_drive

Do you wish to continue? (y/n)"

read wish_to_continue

if [ "$wish_to_continue" != "y" ];
then
	echo "Exiting. No changes have been made."
	exit;
fi

osascript -e 'display notification "Added Script Editor to the list of apps available in the Notification & Focus preference pane." with title "Nightly Time Machine"'
echo "Added Script Editor to the list of apps available in the Notification & Focus preference pane."

drive_info=$(diskutil info "$backup_drive" 2>&1 > /dev/null)

if [[ $drive_info = "Could not find disk: $backup_drive" ]];
	then
	echo "Time Machine disk \"$backup_drive\" is not connected. 
Please connect \"$backup_drive\" and try again. 
Exiting. No changes have been made."
	exit
fi

# Schedule launchd job.
tm_hour=1

if [[ -n $(launchctl list | grep "com.jackwellborn.nightlytimemachine") ]];
then
	echo "Nightly Time Machine job already exists."
else 
	echo "At what hour (0-23) do you want Time Machine to run? 
The default is 1.
"
	read tm_hour_in

	if [[ -n $tm_hour_in ]];
	then
		if [[ $tm_hour_in =~ ^[0-9]+$ ]] && [[ $tm_hour_in -le 23 ]] && [[ $tm_hour_in -ge 0 ]];
		then
			tm_hour=$tm_hour_in
		else 
			echo "\"$tm_hour_in\" is not a valid hour. Exiting. No changes have been made."
			exit
		fi
	fi

	launch_agents_directory="$HOME/Library/LaunchAgents"
	plist_name="com.jackwellborn.nightlytimemachine.plist"
	plist="$launch_agents_directory/$plist_name"

	if [ ! -d "$launch_agents_directory" ];
	then
		echo "Creating LaunchAgents folder in ~/Library"
		mkdir "$launch_agents_directory"
	fi

	script_path=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
	sed "s,%SCRIPT_PATH%,$script_path/," "./com.jackwellborn.nightlytimemachine-template.plist" > "./$plist_name"

	sed "s,%HOUR%,$tm_hour,g" "./$plist_name" > "$plist"

	rm "./$plist_name"
	launchctl load "$plist"
	echo "Scheduled job to run Time Machine at hour $tm_hour."
fi

# Add Time Machine Disk to fstab.
echo "Configuring mounting behavior requires an admin password."
backup_uuid=$(diskutil info "$backup_drive" | sed -rn "s/ +Volume UUID\: +//p")
backup_type=$(diskutil info "$backup_drive" | sed -rn "s/ +Type \(Bundle\)\: +//p")

fstab_entry="UUID=$backup_uuid none $backup_type rw,noauto # $backup_drive"

fstab="/etc/fstab"
if [ ! -f "$fstab" ]
then
	sudo touch $fstab
fi

if [[ ! -z $(sudo grep "^$fstab_entry" "$fstab") ]]
then 
	echo "Time Machine disk \"$backup_drive\" is already configured to not automatically mount when connected."
else
	if [[ $(sudo tail -c 1 $fstab) != "" ]]
	then
		# Add an empty line to fstab when one isn't present
		echo "" | sudo tee -a $fstab 1> /dev/null
	fi
	echo $fstab_entry | sudo tee -a $fstab 1> /dev/null
	echo "Time Machine disk \"$backup_drive\" has been configured to no longer automatically mount when connected."
	backup_is_mounted=$(diskutil info "$backup_drive" | sed -rn "s/ +Mounted\: +//p")
	if [ "$backup_is_mounted" == "Yes" ];
	then
		echo "Would you like to unmount \"$backup_drive\" now? (y/n)"
		read should_unmount
		if [ "$should_unmount" == "y" ];
		then
			unmount_err=$(diskutil unmount "$backup_drive" 2>&1 > /dev/null)
			if [ "$?" -ne 0 ];
			then
				echo "\"$backup_drive\" could not be unmounted at the moment and needs to be unmounted manually."
			else
				echo "\"$backup_drive\" has been unmounted."
			fi
		fi
	fi
fi

