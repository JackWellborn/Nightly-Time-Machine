# Nightly Time Machine
Set and forget Time Machine backups on laptops.

## What
_Nightly Time Machine_ is a collection of bash scripts that limits macOS's [Time Machine][] to once per night by only mounting Time Machine disks just before backing up and then unmounting them when Time Machine is finished. Preventing Time Machine disks from automatically mounting when connected also ensures they can be safely disconnected throughout the day.   

## Why
At it's best, Time Machine is "set it and forget it" in that you should never really have to think about it until a backup is needed or a backup disk needs to be replaced. Time Machine is inarguably at its best on desktops. This isn't surprising, considering [Time Machine was released][] back when [desktops still outsold laptops][]. The biggest indicator that Time Machine is a desktop-first feature is hourly back ups. From Apple's documentation:

> Time Machine automatically makes hourly backups for the past 24 hours, daily backups for the past month, and weekly backups for all previous months. The oldest backups are deleted when your backup disk is full.

Hourly backups make total sense in scenarios where backup disks remain connected indefinitely. On laptops however, where external drives are frequently disconnected, hourly backups are hassle at best and a risk to data at worst. Simply put, Time Machine can't be "set it and forget it" while using a laptop. 

Having recently experienced this degraded experience after replacing an iMac with a MacBook Pro, I saw three outcomes in my future: 

1. Stop using Time Machine
2. Try and remember to unmount the Time Machine disk _every time_ before disconnecting the drive, only to still periodically forget and get dreaded "disk was not ejected properly" notification
3. Figure out a way to only mount and backup to my Time Machine disk during hours that I am least likely to illicitly disconnect it

Nightly backups aren't as good as hourly backups, granted, but they are way better than both non-existant and damaged backups. 

## How
### To Install
1. Download this project to a folder of your choosing 
2. Connect your Time Machine disk
3. In Terminal, navigate to the project folder and run `./Enable Nightly Time Machine.sh`, which makes two changes to your computer:
	1. Schedules a [`launchd`][] job at a specified hour to mount your Time Machine disk, run Time Machine, and then unmount your Time Machine disk
	2. Adds an enty in [`/etc/fstab`][] that will prevent your Time Machine disk from automatically mounting when connected
4. Give bash full disk access in the **Security &amp; Privacy** preference pane
	1. If the lock in the bottom lefthand corner is locked, click it to unlock. This will prompt you for your password.
	2. Click the ＋ (plus) button 
	3. Type "command+shift+g" to bring forward the "Go to" prompt
	4. Type "/bin/bash" to navigate the /bin folder and select bash
	5. With "bash" selected, click the "Open" button to add it to the list of applications that have full disk access
	6. Ensure the checkbox next to "bash" is checked

<img width="764" height="665" src="https://github.com/JackWellborn/Nightly-Time-Machine/blob/main/images/security-and-privacy.png?raw=true" alt="bash with full disk access"></img>

### To Troubleshoot
#### Verify Changes
You can verify that `./Enable Nightly Time Machine.sh` worked as expected by manually checking the changes it's supposed to make:

1. That `/etc/fstab` exists with an entry for your Time Machine disk 
2. That `com.jackwellborn.nightlytimemachine.plist` exists in `~/Library/LaunchAgents` containing xml with `ProgramArguments` of `/bin/bash` and the absolute path of Mount Time `Machine Disk and Back Up.sh`, as well as an `Hour` of whatever hour you set 
3. That the `launchd` job is loaded by running the following command in terminal, which will return something like `-	0	com.jackwellborn.nightlytimemachine` if it's loaded and nothing if not:

```
launchctl list | grep "com.jackwellborn.nightlytimemachine".  
```


### To Uninstall
1. In Terminal, navigate to the project folder and run `Disable Nightly Time Machine.sh`, which makes two changes to your computer:
	1. Removes the `launchd` job that mounts a Time Machine disk, runs Time Machine, and then unmounts your Time Machine disk.
	2. Removes the enty in `/etc/fstab` that prevents your Time Machine disk from automatically mount when connected.

[Time Machine was released]: https://en.wikipedia.org/wiki/Time_Machine_(macOS)
[Time Machine]: https://support.apple.com/en-us/HT201250
[desktops still outsold laptops]: https://arstechnica.com/gadgets/2008/01/2008-could-be-the-year-laptop-sales-eclipse-desktops-in-us/
[`/etc/fstab`]: https://en.wikipedia.org/wiki/Fstab
[`launchd`]: https://en.wikipedia.org/wiki/Launchd
