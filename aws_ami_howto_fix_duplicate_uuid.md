## AMI images create all the machines with same UUID. 
## Problem: can't mount filesystem due to having the same UUID

source: https://www.it3.be/2019/01/09/change-uuid-on-xfs-filesystem/
 

```
[root@myhost ~]# mount /dev/xvdf1 /mount/media1 -t xfs
[ 2038.999943] XFS (xvdf1): Filesystem has duplicate UUID 8ac4868e-a16f-4559-bcb4-5da83479cb0e - can't mount
```

```
[root@myhost ~]# blkid | grep -i UUID
/dev/nvme0n1p2: UUID="b437cbaa-8fe5-49e4-8537-0895c219037a" BLOCK_SIZE="512" TYPE="xfs" PARTUUID="a323d5eb-02"
/dev/nvme1n1p2: LABEL="-f" UUID="b437cbaa-8fe5-49e4-8537-0895c219037a" BLOCK_SIZE="512" TYPE="xfs" PARTUUID="a323d5eb-02"
/dev/nvme0n1: PTUUID="a323d5eb" PTTYPE="dos"
/dev/nvme0n1p1: PARTUUID="a323d5eb-01"
/dev/nvme1n1: PTUUID="a323d5eb" PTTYPE="dos"
/dev/nvme1n1p1: PARTUUID="a323d5eb-01"
```

## Solution: create a new UUID 

```
uuidgen
657ecf72-3823-49e7-904d-4f94d743ceea
```

## Solution: rename UUID and mount.

```
[root@myhost ~]# xfs_admin -L "657ecf72-3823-49e7-904d-4f94d743ceea" -f -U 657ecf72-3823-49e7-904d-4f94d743ceea /dev/nvme1n1p2
Clearing log and setting UUID
writing all SBs
new UUID = 657ecf72-3823-49e7-904d-4f94d743ceea
```


## Mount Filesystem should work now. 

```
[root@myhost ~]# mount /dev/nvme1n1p2  /media/recover/
[root@myhost ~]# cd /media/recover
```

## What about LVM ?
LVM partitions need to be renamed to be mountable.

```
[root@myhost]# vgimportclone /dev/nvme1n1p2
```


## The cloned filesystems should be accessible now but inactive. 

```
[root@myhost mapper]# lvscan
  ACTIVE            '/dev/OS/root' [4.00 GiB] inherit
  ACTIVE            '/dev/OS/tmp' [2.99 GiB] inherit
  ACTIVE            '/dev/OS/var' [2.00 GiB] inherit
  ACTIVE            '/dev/OS/var_tmp' [2.00 GiB] inherit
  ACTIVE            '/dev/OS/var_log' [4.00 GiB] inherit
  ACTIVE            '/dev/OS/var_log_audit' [2.00 GiB] inherit
  ACTIVE            '/dev/OS/swap' [2.00 GiB] inherit
  ACTIVE            '/dev/Data/home' [5.00 GiB] inherit
  ACTIVE            '/dev/Data/var_www' [5.00 GiB] inherit
  inactive          '/dev/OS1/root' [4.00 GiB] inherit
  inactive          '/dev/OS1/tmp' [2.99 GiB] inherit
  inactive          '/dev/OS1/var' [2.00 GiB] inherit
  inactive          '/dev/OS1/var_tmp' [2.00 GiB] inherit
  inactive          '/dev/OS1/var_log' [4.00 GiB] inherit
  inactive          '/dev/OS1/var_log_audit' [2.00 GiB] inherit
  inactive          '/dev/OS1/swap' [2.00 GiB] inherit
  inactive          '/dev/Data1/home' [5.00 GiB] inherit
  inactive          '/dev/Data1/var_www' [5.00 GiB] inherit
```

## enable the LVM partitions

```
[root@myhost ]# vgchange -ay
  7 logical volume(s) in volume group "OS" now active
  2 logical volume(s) in volume group "Data" now active
  7 logical volume(s) in volume group "OS1" now active
  2 logical volume(s) in volume group "Data1" now active
```

## my filesystem still would not mount due to uuid conflicts

logs:
```
[ 9888.615030] XFS (dm-9): Filesystem has duplicate UUID 9e77d1b0-5364-4c91-8895-fee49bf8513e - can't mount
```


## Umount Filestem and rename back 

```
[root@myhost mount1]# cd ..
[root@myhost media]# umount /media/mount1/
```

```
[root@myhost media]# xfs_admin -L 8ac4868e-a16f-4559-bcb4-5da83479cb0e -f -U 8ac4868e-a16f-4559-bcb4-5da83479cb0e /dev/nvme1n1p2
```

```
[root@myhost media]# xfs_repair -L /dev/xvdb1
Phase 1 - find and verify superblock...
Phase 2 - using internal log
        - zero log...
        - scan filesystem freespace and inode maps...
        - found root inode chunk
Phase 3 - for each AG...
        - scan and clear agi unlinked lists...
        - process known inodes and perform inode discovery...
        - agno = 0
        - agno = 1
        - agno = 2
        - agno = 3
        - process newly discovered inodes...
Phase 4 - check for duplicate blocks...
        - setting up duplicate extent list...
        - check for inodes claiming duplicate blocks...
        - agno = 0
        - agno = 1
        - agno = 2
        - agno = 3
Phase 5 - rebuild AG headers and trees...
        - reset superblock...
Phase 6 - check inode connectivity...
        - resetting contents of realtime bitmap and summary inodes
        - traversing filesystem ...
        - traversal finished ...
        - moving disconnected inodes to lost+found ...
Phase 7 - verify and correct link counts...
Maximum metadata LSN (4:4) is ahead of log (1:2).
Format log to cycle 7.
done
```
