## AMI images create all the machines with same UUID. This is fine 
## Problem: can't mount filesystem due to having the same UUID

source: https://www.it3.be/2019/01/09/change-uuid-on-xfs-filesystem/
 

```
[root@myhost ~]# mount /dev/xvdf1 /mount/media1 -t xfs
[ 2038.999943] XFS (xvdf1): Filesystem has duplicate UUID 8ac4868e-a16f-4559-bcb4-5da83479cb0e - can't mount
```

```
[root@myhost ~]# blkid | grep -i UUID
/dev/xvda1: UUID="8ac4868e-a16f-4559-bcb4-5da83479cb0e" TYPE="xfs"
/dev/xvda2: UUID="hYRpWX-wurW-WXDb-W84g-Prht-jadA-KXlyNa" TYPE="LVM2_member"
/dev/xvda3: UUID="dVce5c-YAh7-sDmT-NtDx-zPze-oF16-k9Yh8d" TYPE="LVM2_member"
/dev/mapper/OS-root: UUID="9e77d1b0-5364-4c91-8895-fee49bf8513e" TYPE="xfs"
/dev/mapper/OS-swap: UUID="6094839d-53fc-4953-bca8-00ef792823af" TYPE="swap"
/dev/mapper/OS-tmp: UUID="02316dd0-9b8b-43a0-ab35-0efabf4b2ae8" TYPE="xfs"
/dev/mapper/OS-var: UUID="501a9f86-8ff0-4244-9921-1eef78a0199d" TYPE="xfs"
/dev/mapper/OS-var_tmp: UUID="c4186236-4134-45c0-98a5-b4be21137fb8" TYPE="xfs"
/dev/mapper/OS-var_log: UUID="a683c6b8-46fd-4fd1-b7ed-88bfa3d7a833" TYPE="xfs"
/dev/mapper/OS-var_log_audit: UUID="cb2e4394-b6a0-4971-aa3f-c7bbaa22d849" TYPE="xfs"
/dev/mapper/Data-home: UUID="e6c37c7e-49d2-445b-ba01-7795b2d22eb5" TYPE="xfs"
/dev/mapper/Data-var_www: UUID="22f48d9c-ccf0-453a-8492-bde2a4efc8d3" TYPE="xfs"
/dev/xvdb1: UUID="8ac4868e-a16f-4559-bcb4-5da83479cb0e" TYPE="xfs"
/dev/xvdb2: UUID="hYRpWX-wurW-WXDb-W84g-Prht-jadA-KXlyNa" TYPE="LVM2_member"
/dev/xvdb3: UUID="dVce5c-YAh7-sDmT-NtDx-zPze-oF16-k9Yh8d" TYPE="LVM2_member"
```

## Solution: rename UUID and mount.

```
[root@myhost ~]# xfs_admin -f -U ebc90d35-de21-4466-9304-28cf0a0907a7 /dev/xvdb1
Clearing log and setting UUID
writing all SBs
new UUID = ebc90d35-de21-4466-9304-28cf0a0907a7
```


## Mount Filesystem should work now. 

```
[root@myhost ~]# mount /dev/xvdb1 /media/mount1/
[root@myhost ~]# cd /media/mount1/
```

## What about LVM ?
LVM partitions need to be renamed to be mountable.

```
[root@myhost]# vgimportclone /dev/xvdb3
[root@myhost]# vgimportclone /dev/xvdb3
```

```
[root@myhost ]# blkid | grep -i UUID
/dev/xvda1: UUID="8ac4868e-a16f-4559-bcb4-5da83479cb0e" TYPE="xfs"
/dev/xvda2: UUID="hYRpWX-wurW-WXDb-W84g-Prht-jadA-KXlyNa" TYPE="LVM2_member"
/dev/xvda3: UUID="dVce5c-YAh7-sDmT-NtDx-zPze-oF16-k9Yh8d" TYPE="LVM2_member"
/dev/mapper/OS-root: UUID="9e77d1b0-5364-4c91-8895-fee49bf8513e" TYPE="xfs"
/dev/mapper/OS-swap: UUID="6094839d-53fc-4953-bca8-00ef792823af" TYPE="swap"
/dev/mapper/OS-tmp: UUID="02316dd0-9b8b-43a0-ab35-0efabf4b2ae8" TYPE="xfs"
/dev/mapper/OS-var: UUID="501a9f86-8ff0-4244-9921-1eef78a0199d" TYPE="xfs"
/dev/mapper/OS-var_tmp: UUID="c4186236-4134-45c0-98a5-b4be21137fb8" TYPE="xfs"
/dev/mapper/OS-var_log: UUID="a683c6b8-46fd-4fd1-b7ed-88bfa3d7a833" TYPE="xfs"
/dev/mapper/OS-var_log_audit: UUID="cb2e4394-b6a0-4971-aa3f-c7bbaa22d849" TYPE="xfs"
/dev/mapper/Data-home: UUID="e6c37c7e-49d2-445b-ba01-7795b2d22eb5" TYPE="xfs"
/dev/mapper/Data-var_www: UUID="22f48d9c-ccf0-453a-8492-bde2a4efc8d3" TYPE="xfs"
/dev/xvdb1: UUID="ebc90d35-de21-4466-9304-28cf0a0907a7" TYPE="xfs"
/dev/xvdb2: UUID="6cMAiz-41NM-pVxA-gx5L-u8sg-UmWK-KF2VDk" TYPE="LVM2_member"
/dev/xvdb3: UUID="5GEzG8-l1xQ-queN-KAhX-HpPp-1JHD-iyGwCd" TYPE="LVM2_member"
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

```
[root@myhost ]# blkid | grep 9e77d
/dev/mapper/OS-root: UUID="9e77d1b0-5364-4c91-8895-fee49bf8513e" TYPE="xfs"
/dev/mapper/OS1-root: UUID="9e77d1b0-5364-4c91-8895-fee49bf8513e" TYPE="xfs"
```


```
[root@myhost ]# uuidgen
1749489e-14b5-4974-9fa4-6ce7ef38ae5d
[root@myhost ]# xfs_admin -f -U 1749489e-14b5-4974-9fa4-6ce7ef38ae5d /dev/OS1/root
Clearing log and setting UUID
writing all SBs
new UUID = 1749489e-14b5-4974-9fa4-6ce7ef38ae5d
```

## Umount Filestem and rename back 

```
[root@myhost mount1]# cd ..
[root@myhost media]# umount /media/mount1/
```

```
[root@myhost media]# xfs_admin -f -U 8ac4868e-a16f-4559-bcb4-5da83479cb0e /dev/xvdb1
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