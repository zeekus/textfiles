# identify disks on system

```
[root@myhost ~]# lsscsi
[N:0:0:1]    disk    Amazon Elastic Block Store__1              /dev/nvme0n1
[N:1:0:1]    disk    Amazon Elastic Block Store__1              /dev/nvme1n1
```

# identify prations

main disk 

```
[root@myhost ~]# fdisk -l /dev/nvme0n1
Disk /dev/nvme0n1: 30 GiB, 32212254720 bytes, 62914560 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xa323d5eb

Device         Boot Start      End  Sectors Size Id Type
/dev/nvme0n1p1       2048     4095     2048   1M 83 Linux
/dev/nvme0n1p2 *     4096 62914526 62910431  30G 83 Linux
```

extra disk not mounted

```
[root@myhost ~]# fdisk -l /dev/nvme1n1
Disk /dev/nvme1n1: 35 GiB, 37580963840 bytes, 73400320 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 5B2BADF5-4774-B547-A045-E53D67DC3C63
```


# create physical volume group with new disk

```
[root@myhost ~]# pvcreate /dev/nvme1n1
```


# create or extend volume group with new disk  
  
 Create new volume group if no volume group exists or extend existing one
 
 commands: 
 ```
 vgcreate 
 vgextend
 ```

``` 
 [root@myhost ~]# vgcreate /dev/MyVG01 /dev/nvme1n1
  Volume group "MyVG01" successfully created
```

# format filesystem

```
[root@myhost ~]# mkfs.xfs /dev/MyVG01/Data
meta-data=/dev/MyVG01/Data       isize=512    agcount=4, agsize=2228224 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1
data     =                       bsize=4096   blocks=8912896, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=4352, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
```

## add newly formated volume to fstab 

# 1. find uuid for volume

```
[root@myhost ~]# blkid
/dev/nvme1n1: UUID="QCRiG3-z0Qy-1BQ6-0mQ9-JQSK-Xc9G-oYKHlW" TYPE="LVM2_member"
/dev/nvme0n1: PTUUID="a323d5eb" PTTYPE="dos"
/dev/nvme0n1p1: PARTUUID="a323d5eb-01"
/dev/nvme0n1p2: UUID="b437cbaa-8fe5-49e4-8537-0895c219037a" TYPE="xfs" PARTUUID="a323d5eb-02"
/dev/mapper/MyVG01-Data: UUID="6df2a46f-95bf-4e0d-b799-1394cb982e9c" TYPE="xfs"
```

# 2. Edit fstab
orginal
```
[centos@myhost ~]$ cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Thu Jun 11 02:35:22 2020
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
UUID=b437cbaa-8fe5-49e4-8537-0895c219037a /                       xfs     defaults        0 0
```

# 3. added lvm 

```
[centos@myhost ~]$ cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Thu Jun 11 02:35:22 2020
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
UUID=b437cbaa-8fe5-49e4-8537-0895c219037a /                       xfs     defaults        0 0
UUID=6df2a46f-95bf-4e0d-b799-1394cb982e9c /media                  xfs     defaults        1 1 
```

# 4. run mount to test

```
[root@myhost ~]# mount -a
```


# 5. verify mount was added

```
[root@myhost ~]# journalctl | grep -i mount | tail -3
Oct 27 07:54:38 myhost.example.net systemd[1]: Started /run/user/1000 mount wrapper.
Oct 27 08:00:30 myhost.example.net kernel: XFS (dm-0): Mounting V5 Filesystem
Oct 27 08:00:30 myhost.example.net kernel: XFS (dm-0): Ending clean mount


[root@myhost ~]# df -h
Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                 867M     0  867M   0% /dev
tmpfs                    895M     0  895M   0% /dev/shm
tmpfs                    895M   17M  879M   2% /run
tmpfs                    895M     0  895M   0% /sys/fs/cgroup
/dev/nvme0n1p2            30G  3.1G   27G  11% /
tmpfs                    179M     0  179M   0% /run/user/1000
/dev/mapper/MyVG01-Data   34G  275M   34G   1% /media
```









  
