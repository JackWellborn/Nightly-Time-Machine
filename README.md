# Nightly Time Machine
Set and forget Time Machine backups on laptops.

## What
_Nightly Time Machine_ is a collection of bash scripts that limits macOS's [Time Machine][] to once per night by only mounting Time Machine disks just before backing up and then unmounting them when Time Machine is finished. Preventing Time Machine disks from automatically mounting when connected also ensures they can be safely disconnected throughout the day.   

## Why
At its best, Time Machine is "set it and forget it" in that you should never really have to think about it until a backup is needed or a backup disk needs to be replaced. Time Machine by itself is only at its best on desktops. On laptops, where external drives are frequently disconnected, Time Machine becomes a hassle at best and a risk to data at worst. With _Nightly Time Machine_, Time Machine is "set it and forget it" on laptops.

## How
### To Install
1. Download this project to a folder of your choosing 
2. Connect your Time Machine disk
3. In Terminal, navigate to the project folder and run `./Enable Nightly Time Machine.sh`, which makes two changes to your computer:
	1. Schedules a [`launchd`][] job at a specified hour to mount your Time Machine disk, run Time Machine, and then unmount your Time Machine disk
	2. Adds an entry in [`/etc/fstab`][] that will prevent your Time Machine disk from automatically mounting when connected
4. Give bash full disk access in the **Security &amp; Privacy** preference pane
	1. If the lock in the bottom lefthand corner is locked, click it to unlock. This will prompt you for your password.
	2. Click the ＋ (plus) button 
	3. Type "command+shift+g" to bring forward the "Go to" prompt
	4. Type "/bin/bash" to navigate the /bin folder and select bash
	5. With "bash" selected, click the "Open" button to add it to the list of applications that have full disk access
	6. Ensure the checkbox next to "bash" is checked<br/><img width="764" height="665" src="https://github.com/JackWellborn/Nightly-Time-Machine/blob/main/images/security-and-privacy.png?raw=true" alt="bash with full disk access"></img>
5. Prevent automatically sleeping when connected to power in the **Battery** preference pane
	1. Select "Power adapter" in the lefthand side
	2. Ensure "Prevent your Mac from automatically sleeping when the display is off" is checked<br/><img width="780" height="622" src="https://raw.githubusercontent.com/JackWellborn/Nightly-Time-Machine/main/images/battery.png?raw=true" alt="Script Editor notification settings"></img>
6. (Optionally) Adjust notifications for Script Editor in the **Notifications &amp; Focus** preference pane to alert when _Nightly Time Machine_ completes or fails
	1. Ensure "Allow Notification" toggle is on
	2. Set "Script Editor alert style" to "Alerts"
	3. Set "Notification grouping" to "off"<br/><img width="780" height="839" src="https://raw.githubusercontent.com/JackWellborn/Nightly-Time-Machine/main/images/notifications-and-focus.png?raw=true" alt="Script Editor notification settings"></img>

### To Troubleshoot
#### Verify Changes
You can verify that `./Enable Nightly Time Machine.sh` worked as expected by manually checking the changes it's supposed to make:

1. That `/etc/fstab` exists with an entry for your Time Machine disk 
2. That `com.jackwellborn.nightlytimemachine.plist` exists in `~/Library/LaunchAgents` containing xml with `ProgramArguments` of `/bin/bash` and the absolute path of Mount Time `Machine Disk and Back Up.sh`, as well as an `Hour` of whatever hour you set 
3. That the `launchd` job is loaded by running the following command in terminal, which will return something like `-	0	com.jackwellborn.nightlytimemachine` if it's loaded and nothing if not:

```
launchctl list | grep "com.jackwellborn.nightlytimemachine"
```

### To Uninstall
1. In Terminal, navigate to the project folder and run `Disable Nightly Time Machine.sh`, which makes two changes to your computer:
	1. Removes the `launchd` job that mounts a Time Machine disk, runs Time Machine, and then unmounts your Time Machine disk.
	2. Removes the entry in `/etc/fstab` that prevents your Time Machine disk from automatically mount when connected.

## Updates
### 2022-09-12
#### Fixed issue with macOS Ventura Public Beta 5
Apple's `diskutil` fails to mount the Time Machine disk using the disk name in macOS Ventura pubic beta 5 so `Mount Time Machine Disk and Back Up.sh` has been updated to use the volume UUID instead. I suspect the mounting issue is temporary, but there doesn't seem to be any downside to just using the volume UUID going forward.

[Time Machine was released]: https://en.wikipedia.org/wiki/Time_Machine_(macOS)
[Time Machine]: https://support.apple.com/en-us/HT201250
[desktops still outsold laptops]: https://arstechnica.com/gadgets/2008/01/2008-could-be-the-year-laptop-sales-eclipse-desktops-in-us/
[`/etc/fstab`]: https://en.wikipedia.org/wiki/Fstab
[`launchd`]: https://en.wikipedia.org/wiki/Launchd
