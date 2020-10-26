
## Title: How to resize swap on LVM to use it elsewhere
## Problem: The server has a 2GB /var/tmp partion. Backups are larger than 2GB. 

## verify we don't have any free space available

#pvdisplay - Display various attributes of physical volume(s)

```
[root@server0 ]# pvdisplay
  --- Physical volume ---
  PV Name               /dev/nvme0n1p3
  VG Name               OS
  PV Size               <19.00 GiB / not usable 3.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              4862
  Free PE               0
  Allocated PE          4862
  PV UUID               dVce5c-YAh7-sDmT-NtDx-zPze-oF16-k9Yh8d

  --- Physical volume ---
  PV Name               /dev/nvme0n1p2
  VG Name               Data
  PV Size               10.00 GiB / not usable 4.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              2560
  Free PE               0
  Allocated PE          2560
  PV UUID               hYRpWX-wurW-WXDb-W84g-Prht-jadA-KXlyNa
```

# No physical disk space mesans we may need to shuffle stuff around.
# Possible solution: use swap space to resize /var/tmp  

```
[root@server0 ]# df -h | grep -i var_tmp
/dev/mapper/OS-var_tmp        2.0G   37M  2.0G   2% /var/tmp
```

# swap is 2GB. We could use 1GB of it. 

```
[root@server0 ]#  cat /proc/swaps
Filename                                Type            Size    Used    Priority
/dev/dm-1                               partition       2097148 294656  -2


[root@server0 jmassey]# lvs -a -o +devices
  LV            VG   Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices
  home          Data -wi-ao---- 5.00g                                                     /dev/nvme0n1p2(0)
  var_www       Data -wi-ao---- 5.00g                                                     /dev/nvme0n1p2(1280)
  root          OS   -wi-ao---- 4.00g                                                     /dev/nvme0n1p3(0)
  swap          OS   -wi-a----- 2.00g                                                     /dev/nvme0n1p3(4350)
  tmp           OS   -wi-ao---- 2.99g                                                     /dev/nvme0n1p3(1024)
  var           OS   -wi-ao---- 2.00g                                                     /dev/nvme0n1p3(1790)
  var_log       OS   -wi-ao---- 4.00g                                                     /dev/nvme0n1p3(2814)
  var_log_audit OS   -wi-ao---- 2.00g                                                     /dev/nvme0n1p3(3838)
  var_tmp       OS   -wi-ao---- 2.00g                                                     /dev/nvme0n1p3(2302)
```  
  

## Check the drives and logical volumes again

# pvs - Display information about physical volumes

```
  [root@server0 ]# pvs
  PV             VG   Fmt  Attr PSize  PFree
  /dev/nvme0n1p2 Data lvm2 a--  10.00g    0
  /dev/nvme0n1p3 OS   lvm2 a--  18.99g    0
```

  
# vgs - Display information about volume groups

```
[root@server0 ]# vgs
  VG   #PV #LV #SN Attr   VSize  VFree
  Data   1   2   0 wz--n- 10.00g    0
  OS     1   7   0 wz--n- 18.99g    0
```

# lvs - Display information about logical volumes

```  
[root@server0 ]# lvs
  LV            VG   Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home          Data -wi-ao---- 5.00g
  var_www       Data -wi-ao---- 5.00g
  root          OS   -wi-ao---- 4.00g
  swap          OS   -wi-a----- 2.00g
  tmp           OS   -wi-ao---- 2.99g
  var           OS   -wi-ao---- 2.00g
  var_log       OS   -wi-ao---- 4.00g
  var_log_audit OS   -wi-ao---- 2.00g
  var_tmp       OS   -wi-ao---- 2.00g
``` 
  
  
# lvdisplay - Display information about a logical volume ( swap) 
  
```   
  [root@server0 ]# lvdisplay /dev/OS/swap
  --- Logical volume ---
  LV Path                /dev/OS/swap
  LV Name                swap
  VG Name                OS
  LV UUID                SiGkVu-0luH-rBBf-bv5Z-I0Tn-Pcrn-bBVLvZ
  LV Write Access        read/write
  LV Creation host, time limg5d.example.net, 2018-05-02 12:27:27 -0400
  LV Status              available
  # open                 0
  LV Size                2.00 GiB
  Current LE             512
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:1
```

## Start the changes

# disable/unmount the swap partion *pending the system is not swapping*
```
swapoff -a
```

# shrink the swap partion 1 GB  

```
[root@server0]# lvreduce -L 1G  /dev/OS/swap
  WARNING: Reducing active logical volume to 1.00 GiB.
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce OS/swap? [y/n]: y
  Size of logical volume OS/swap changed from 2.00 GiB (512 extents) to 1.00 GiB (256 extents).
  Logical volume OS/swap successfully resized.
```  
  
# reformat the smaller swap volume

```
[root@server0]# mkswap /dev/OS/swap
mkswap: /dev/OS/swap: warning: wiping old swap signature.
Setting up swapspace version 1, size = 1048572 KiB
no label, UUID=decb093d-1791-4af2-9203-96261b172591
```

# remount and  verify

```
[root@server0 tmp]# swapon -a
```

# verify swap size got smaller

```
                                             
[root@server0 tmp]# lvdisplay /dev/OS/swap
  --- Logical volume ---
  LV Path                /dev/OS/swap
  LV Name                swap
  VG Name                OS
  LV UUID                SiGkVu-0luH-rBBf-bv5Z-I0Tn-Pcrn-bBVLvZ
  LV Write Access        read/write
  LV Creation host, time limg5d.example.net, 2018-05-02 12:27:27 -0400
  LV Status              available
  # open                 2
  LV Size                1.00 GiB
  Current LE             256
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:1
```

# backup data from /var/tmp
# install xfsdump for this

```
yum install xfsdump -y

[root@server0 tmp]# xfsdump -f /root/var_tmp.dump /var/tmp
xfsdump: using file dump (drive_simple) strategy
xfsdump: version 3.1.7 (dump format 3.0) - type ^C for status and control

 ============================= dump label dialog ==============================

please enter label for this dump session (timeout in 300 sec)
 -> backup_var_tmp
session label entered: "backup_var_tmp"

 --------------------------------- end dialog ---------------------------------

xfsdump: level 0 dump of server0.us-east.aws.example.net:/var/tmp
xfsdump: dump date: Mon Oct 26 11:01:22 2020
xfsdump: session id: 37c6f059-2502-4bdd-abae-6a836fb0ed95
xfsdump: session label: "backup_var_tmp"
xfsdump: ino map phase 1: constructing initial dump list
xfsdump: ino map phase 2: skipping (no pruning necessary)
xfsdump: ino map phase 3: skipping (only one dump stream)
xfsdump: ino map construction complete
xfsdump: estimated dump size: 3913024 bytes
xfsdump: /var/lib/xfsdump/inventory created

 ============================= media label dialog =============================

please enter label for media in drive 0 (timeout in 300 sec)
 -> exit
media label entered: "exit"

 --------------------------------- end dialog ---------------------------------

xfsdump: creating dump session media file 0 (media 0, file 0)
xfsdump: dumping ino map
xfsdump: dumping directories
xfsdump: dumping non-directory files
xfsdump: ending media file
xfsdump: media file size 3911040 bytes
xfsdump: dump size (non-dir files) : 3879144 bytes
xfsdump: dump complete: 29 seconds elapsed
xfsdump: Dump Summary:
xfsdump:   stream 0 /root/var_tmp.dump OK (success)
xfsdump: Dump Status: SUCCESS
```

# verify backup exists

```
[root@server0 ~]# ls -lah var_tmp.dump
-rw-r--r--. 1 root root 3.8M Oct 26 11:01 var_tmp.dump
```

# umount the /var/tmp partition 

```
[root@server0 tmp]# cd /
[root@server0 ~]# umount /var/tmp/
```

# resize /var/tmp

[ add 1G to the 2GB /var/tmp ]

```
[root@server0]# lvextend -L 3G  /dev/OS/var_tmp
  Size of logical volume OS/var_tmp changed from 2.00 GiB (512 extents) to 3.00 GiB (768 extents).
  Logical volume OS/var_tmp successfully resized.
```

# grow xfs filessystem or format if you don't have an option to grow the filesystem

```
[root@server0 ~]# xfs_growfs /dev/OS/var_tmp
meta-data=/dev/mapper/OS-var_tmp isize=512    agcount=4, agsize=131072 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=524288, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 524288 to 786432
```

# verify size changed

```
[root@server0 ~]# lvdisplay /dev/OS/var_tmp
  --- Logical volume ---
  LV Path                /dev/OS/var_tmp
  LV Name                var_tmp
  VG Name                OS
  LV UUID                02YvHy-fPBG-Mfqq-Vg8A-Xlbs-0VT2-cL74fG
  LV Write Access        read/write
  LV Creation host, time limg5d.example.net, 2018-05-02 12:27:26 -0400
  LV Status              available
  # open                 1
  LV Size                3.00 GiB
  Current LE             768
  Segments               2
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:4
```

# reboot and verify everything still works

```
reboot
```




  
