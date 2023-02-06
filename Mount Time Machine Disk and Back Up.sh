#!/bin/sh

output() {
	response=$1
	status=$2
	echo "$response"
	osascript -  "$response" "$status"  <<EOF
	on run argv -- argv is a list of strings
		display notification (item 1 of argv) with title (item 2 of argv)
	end run
EOF
}

unmount() {
	backup_succeeded=$1
	backup_status_message=$2
	response="Time Machine backup completed"
	unmount_err=$(diskutil unmount "$backup_uuid" 2>&1 > /dev/null)
	if [ "$?" -ne 0 ]; then
		mount_status="the backup drive failed to unmount"
		if [[ "$backup_succeeded" = true ]];
		then
			output "$response, but $mount_status." "Unmount Failed"
		else
			response="Backup stopped before completing"
			output "$response and $mount_status." "Backup and Unmount Failed"
		fi
	else
		mount_status="the backup drive was unmounted successfully"
		if [[ "$backup_succeeded" = true ]];
		then
			output "$response and $mount_status." "Backup Complete"
		else
			response="Backup stopped before completing"
			output "$response, but $mount_status." "Backup and Unmount Failed"
		fi
	fi 
		
}

backup_drive=$(tmutil destinationinfo | sed -rn 's/(Name +\: )//p')
tm_timeout=120

drive_info=$(diskutil info "$backup_drive" 2>&1 > /dev/null)
if [[ $drive_info = "Could not find disk: $backup_drive" ]];
	then
	output "Time Machine disk \"$backup_drive\" is not connected." "Backup Failed"
	exit
fi
backup_uuid=$(diskutil info "$backup_drive" | sed -rn "s/ +Volume UUID\: +//p")
diskutil mount "$backup_uuid"

tmutil startbackup

# Sometimes it takes a few seconds for Time Machine to start. 
while [ $(tmutil currentphase) == 'BackupNotRunning' ];
	do
	tm_timeout=$(($tm_timeout-1))
	if [[ $tm_timeout -le 0 ]];
		then
		unmount false "Time Machine backup to \"$backup_drive\" was unable to start."
		exit
	fi
	sleep 1
done;

tm_stopped=false
# Wait until Time Machine is no long running, then unmount.
while [ $(tmutil currentphase) != 'BackupNotRunning' ]; 
	do 
	if [[ $(tmutil currentphase) = 'Stopping' ]];
		then
		tm_stopped=true
		break
	fi
	echo 'Waiting for backup to complete.'
	sleep 10
done;

if [[ "$tm_stopped" = true ]];
then
	unmount false "Backup stopped before completing"
	exit
fi
unmount true "Time Machine backup completed"


