

# Problem: Ocassionally data need to be recovered from a snapshot that holds LVM partions. 

# Solution: mount drive to a system with different LVM labels. 
*NOTE use a Amazon AMI to prevent LVM lables from getting renamed.

## add the volume to the instance [ the label given can be anything. ] 

## verify the volume mounted

*before attching volume to system
```
[ec2-user@myhost ~]$ blkid
/dev/xvda1: LABEL="/" UUID="a7bc2c27-ef92-4f49-8259-a3adb5264131" TYPE="ext4" PARTLABEL="Linux" PARTUUID="94d75765-a40f-44b0-9330-de1e046abdca"
```

*after attaching volume to system
```
[ec2-user@myhost ~]$ blkid
/dev/xvda1: LABEL="/" UUID="a7bc2c27-ef92-4f49-8259-a3adb5264131" TYPE="ext4" PARTLABEL="Linux" PARTUUID="94d75765-a40f-44b0-9330-de1e046abdca"
/dev/xvdf1: UUID="2c2e8abf-07c1-453b-8091-10a73fe33b75" TYPE="xfs"
```

## mount the new volume on your recovery host

```
mkdir -p /media/lvm
mount /dev/xvdf1 /media/lvm
```

## scan the lvm partions

```
[root@myhost ~]# lvdisplay -v
  --- Logical volume ---
  LV Path                /dev/OS/root
  LV Name                root
  VG Name                OS
  LV UUID                4ZPZOV-igMU-1k3d-jOmZ-weod-PhHf-MRudcy
  LV Write Access        read/write
  LV Creation host, time limg5d.example.net, 2018-05-02 16:27:24 +0000
  LV Status              available
  # open                 0
  LV Size                4.00 GiB
  Current LE             1024
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0
...
```


## create a mount point of the virtual point and mount it

```

[root@myhost ~]# mkdir -p /media/lvm-root
[root@myhost ~]# mount /dev/OS/root /media/lvm-root/
```

## after recovering or modifying the data remember to unmount the drive and verify

```
[root@myhost ~]# umount /media/lvm-root /media/lvm
[root@myhost ~]# df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        483M  112K  483M   1% /dev
tmpfs           493M     0  493M   0% /dev/shm
/dev/xvda1      7.9G  1.2G  6.6G  15% /
```

## detach the volume and attach to host desired to run 



