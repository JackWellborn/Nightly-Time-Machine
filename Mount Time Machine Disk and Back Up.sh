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
		output "Time Machine backup to \"$backup_drive\" was unable to start." "Backup Failed"
		exit
	fi
	sleep 1
done;

# Wait until Time Machine is no long running, then unmount.
while [ $(tmutil currentphase) != 'BackupNotRunning' ]; 
	do 
	echo 'Waiting for backup to complete.'
	sleep 10
done;

response="Time Machine backup completed"
unmount_err=$(diskutil unmount "$backup_uuid" 2>&1 > /dev/null)
if [ "$?" -ne 0 ]; then
	output "$response, but \"$backup_drive\" failed to unmount." "Unmount Failed"
else 
	output "$response and \"$backup_drive\" has been unmounted." "Backup Complete"
fi
