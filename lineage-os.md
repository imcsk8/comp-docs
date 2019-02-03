# Lineage OS 
Lineage OS is an Android distribution for mobile devices. This are just notes for installing and managing this OS.

## Lineage OS on Samsung Galaxy S9

### Install Custom Recovery


*On Fedora we use heimdall*

**Install heimdall**

```
# dnf install -y heimdall heimdall-frontend
```

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
