|Problem                                                                                            | Senario|
|---------------------------------------------------------------------------------------------------|-------------------------------------------------------------------|
When mounting a LVM volume on a host with similar drive settings the labels for LVM can change. This can happen if you use a Amazon AMI of another host as a recovery agent. To prevent this, a special AMI should be created as a recovery agent with differnt LVM labels.   | After a system was restored, a LVM volume on '/dev/xvda2' is not accessible.|




## Display the physical LVM volumes that are mounted.

```
[root@myhost html]# pvdisplay
  --- Physical volume ---
  PV Name               /dev/xvda3
  VG Name               OS
  PV Size               <19.00 GiB / not usable 3.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              4862
  Free PE               0
  Allocated PE          4862
  PV UUID               dVce5c-YAh7-sDmT-NtDx-zPze-oF16-k9Yh8d

  --- Physical volume ---
  PV Name               /dev/xvda2
  VG Name               Data1
  PV Size               10.00 GiB / not usable 4.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              2560
  Free PE               0
  Allocated PE          2560
  PV UUID               EhB0eI-VRou-6XHu-XNy7-P0hg-c13Q-vfIxeA
```

## Double check the lvm device maps

```
[root@myhost html]# lvs -a -o +devices
  LV            VG    Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices
  home          Data1 -wi-a----- 5.00g                                                     /dev/xvda2(0)
  var_www       Data1 -wi-a----- 5.00g                                                     /dev/xvda2(1280)
  root          OS    -wi-ao---- 4.00g                                                     /dev/xvda3(0)
  swap          OS    -wi-ao---- 2.00g                                                     /dev/xvda3(4350)
  tmp           OS    -wi-ao---- 2.99g                                                     /dev/xvda3(1024)
  var           OS    -wi-ao---- 2.00g                                                     /dev/xvda3(1790)
  var_log       OS    -wi-ao---- 4.00g                                                     /dev/xvda3(2814)
  var_log_audit OS    -wi-ao---- 2.00g                                                     /dev/xvda3(3838)
  var_tmp       OS    -wi-ao---- 2.00g                                                     /dev/xvda3(2302)
```

## Display the LVM volumes that are active/inactive.

```
[root@myhost html]# lvscan
  ACTIVE            '/dev/OS/root' [4.00 GiB] inherit
  ACTIVE            '/dev/OS/tmp' [2.99 GiB] inherit
  ACTIVE            '/dev/OS/var' [2.00 GiB] inherit
  ACTIVE            '/dev/OS/var_tmp' [2.00 GiB] inherit
  ACTIVE            '/dev/OS/var_log' [4.00 GiB] inherit
  ACTIVE            '/dev/OS/var_log_audit' [2.00 GiB] inherit
  ACTIVE            '/dev/OS/swap' [2.00 GiB] inherit
  ACTIVE            '/dev/Data1/home' [5.00 GiB] inherit
  ACTIVE            '/dev/Data1/var_www' [5.00 GiB] inherit
```


## If a LVM volume is not active rescan and make active using this command.

```
[root@myhost html]# vgscan -yn
  Reading volume groups from cache.
  Found volume group "OS" using metadata type lvm2
  Found volume group "Data1" using metadata type lvm2
```

## Attempt to mount the volumes from the command line.
* Note, if a drive is set to 'nofail' the command will not display issues.

```
[root@myhost html]# mount -a
mount: special device /dev/mapper/Data-home does not exist
mount: special device /dev/mapper/Data-var_www does not exist
```

In this senario, the system was attmepting to mount 'Data' rather than 'Data1'.
All the 'Data' label changed on a restore task.

## Verify the /etc/fstab file points to the correct path 

In this senario, they do not.

```
[root@myhost html]# cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Wed May  2 12:27:29 2018
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/OS-root                             /               xfs     defaults        0 0
UUID=8ac4868e-a16f-4559-bcb4-5da83479cb0e       /boot           xfs     defaults        0 0
/dev/mapper/Data-home                           /home           xfs     defaults        0 0
/dev/mapper/OS-tmp                              /tmp            xfs     defaults        0 0
/dev/mapper/OS-var                              /var            xfs     defaults        0 0
/dev/mapper/OS-var_log                          /var/log        xfs     defaults        0 0
/dev/mapper/OS-var_log_audit                    /var/log/audit  xfs     defaults        0 0
/dev/mapper/OS-var_tmp                          /var/tmp        xfs     defaults        0 0
/dev/mapper/Data-var_www                        /var/www        xfs     defaults        0 0
/dev/mapper/OS-swap                             swap            swap    defaults        0 0
/dev/xvdc1                                      /var/www/html   xfs     defaults,nofail 0 0
```

# Final note Best Practice

It is not a best practice to mount devices by static devices. These can also change.
'/dev/xvdc1' could change. Identify the UUID and mount by UUID.

```
[root@myhost html]# blkid | grep xvdc1
/dev/xvdc1: UUID="9e77d1b0-5364-4c91-8895-fee49bf8513e" TYPE="xfs"
```

In /etc/fstab Change the device entry to UUID. 

```
/dev/xvdc1                                      /var/www/html   xfs     defaults,nofail 0 0
```
*change to*
```
UUID=9e77d1b0-5364-4c91-8895-fee49bf8513e      /var/www/html   xfs     defaults,nofail 0 0
```

Also, in many virtual environments if a drive mount fails you will not be able to start the host or access it.
Mounting drives with the 'nofail' option, allows machines to startup even if a drive does not mount. This may allow you greater flexibility in troubleshooting later if needed. 
