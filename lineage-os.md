# Lineage OS 
Lineage OS is an Android distribution for mobile devices. This are just notes for installing and managing this OS.

## Lineage OS on Samsung Galaxy S9

### Install Custom Recovery


*On Fedora we use heimdall*

**Install heimdall**

```
# dnf install -y heimdall heimdall-frontend
```

**Unlock the device**
The US models can't be unlocked but the SM-G9600/SM-G9650 can :D

* Go to Settings>>About Phone>>Software Information.
* Locate the Build Number option and tap it 5-7 times quickly to enable the Developer Options.
* Go back to Main Settings page and locate the newly added Developer Options
* On Developer Options, enable the OEM unlock.

If the device is less than 7 days old the ```OEM unlock``` option will not appear so we have to wait :/


**Download TWRP**

```
$ cd Downloads
$ wget https://dl.twrp.me/starlte/twrp-3.2.3-0-starlte.img
```

* Power off the device
* Boot into download mode:
  * With the device powered off, hold ``Volume Down`` + ``Bixby`` + ``Power``.
* Once de device is in download mode use *heimdal* to save the custom recovery

```
# heimdall flash --RECOVERY twrp-3.2.3-0-starlte.img --no-reboot
```


# References
https://wiki.lineageos.org/devices/starlte

https://wiki.lineageos.org/devices/starlte/install

https://download.lineageos.org/starlte

https://dl.twrp.me/starlte/

https://www.goandroid.co.in/unlock-bootloader-of-galaxy-s9-plus-snapdragon/84688/

https://www.xda-developers.com/fix-missing-oem-unlock-samsung-galaxy-s9-samsung-galaxy-s8-samsung-galaxy-note-8/
