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
3. In Finder, navigate to the project folder and double click `./Enable Nightly Time Machine.command`, which makes two changes to your computer:
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

#### Solved Issues
##### Time Machine stops before completing backups
Backups can prematurely stop because Time Machine erroneously loses access to some files when the Mac is locked. While in this state, the issue occurs even when running Time Machine and locking the Mac manually. When Time Machine fails in this manner, you can see the following error in Time Machine Settings:

> Time Machine did not finish backing up because some files were unavailable. Backups will resume when your Mac is unlocked.

The following steps should resolve the issue:

1. [Restart your Mac in Recovery mode][].
2. In Recovery mode, open Disk Utility.
3. In Disk Utility, [run First Aid on each of the Disks][] listed in the lefthand side.

### To Uninstall
1. In Finder, navigate to the project folder and double click `./Disable Nightly Time Machine.command`, which makes two changes to your computer:
	1. Removes the `launchd` job that mounts a Time Machine disk, runs Time Machine, and then unmounts your Time Machine disk.
	2. Removes the entry in `/etc/fstab` that prevents your Time Machine disk from automatically mount when connected.

## Updates
### 2023-02-12
#### Detailed fix for premature stopping in this README
As the issue wherein Time Machine unexpectedly stops still appears to be resolved, I have detailed the fix in a new "Solved Issues" section in this document.

#### Reordered updates to be reverse chronological  
As time goes on, I feel that more recent updates are more likely be relevant to future users of this project and so they should go on top.

### 2023-02-06
#### Unmount the Time Machine disk when the backup fails
Now the script will try to unmount a mounted Time Machine disk even when the backup fails. 

#### Update on the issue where Time Machine unexpectedly stops
After researching the issue some more, I stumbled across [this thread and comment on the MacRumors forums][] that suggested running First Aid in Disk Utility resolves the issue despite finding no issues with the disks being scanned. I gave it a whirl and sure enough, this seemed to fix my issue for now. I will give it a few days to confirm before resolving the [associated issue][]. 

### 2023-02-01
#### Surfaces error for when Time Machine stops unexpectedly
At somepoint after installing Ventura, I've noticed some backups would stop with the following error:
> Time Machine did not finish backing up because some files were unavailable. Backups will resume when your Mac is unlocked.

While I have yet to workaround this issue, I have updated out to capture and output when backups unexpectedly stop.

#### Rename enable and disable scripts to use `.command` extension
Per [Chuck Houpt][]'s [recommendation][], using `.command` makes it possible to execute these scripts merely by double clicking on them in Finder, which is both easier and less intimidating for those not familiar with the Terminal. 

### 2022-09-12
#### Fixed issue with macOS Ventura Public Beta 5
Apple's `diskutil` fails to mount the Time Machine disk using the disk name in macOS Ventura pubic beta 5 so `Mount Time Machine Disk and Back Up.sh` has been updated to use the volume UUID instead. I suspect the mounting issue is temporary, but there doesn't seem to be any downside to just using the volume UUID going forward.




[Time Machine was released]: https://en.wikipedia.org/wiki/Time_Machine_(macOS)
[Time Machine]: https://support.apple.com/en-us/HT201250
[desktops still outsold laptops]: https://arstechnica.com/gadgets/2008/01/2008-could-be-the-year-laptop-sales-eclipse-desktops-in-us/
[`/etc/fstab`]: https://en.wikipedia.org/wiki/Fstab
[`launchd`]: https://en.wikipedia.org/wiki/Launchd
[Chuck Houpt]: https://github.com/chuckhoupt
[recommendation]: https://github.com/JackWellborn/Nightly-Time-Machine/issues/5
[this thread and comment on the MacRumors forums]: https://forums.macrumors.com/threads/time-machine-experiencing-multiple-issues-on-monterey-my-personal-issue-resolved.2319832/page-22?post=30710422#post-30710422
[associated issue]: https://github.com/JackWellborn/Nightly-Time-Machine/issues/4
[Restart your Mac in Recovery mode]: https://support.apple.com/guide/mac-help/intro-to-macos-recovery-mchl46d531d6/mac
[run First Aid on each of the Disks]: https://support.apple.com/guide/mac-help/macos-recovery-a-mac-apple-silicon-mchl82829c17/13.0/mac/13.0#mchl3fe49482
