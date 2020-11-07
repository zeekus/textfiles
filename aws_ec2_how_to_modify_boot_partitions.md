
DRAFT: This solution doesn't work as of 11/6/2020


EC2 typically is only available in headless mode for most people.
Additionally, most marketplace AMI come with one partition.

Problem: My ec2 instance only has one partition, but I want more.


Centos7 AMI:
Region: Ohio / us-east1b


# blkid
```
[root@mysourcehost ~]# blkid
/dev/xvda1: UUID="6cd50e51-cfc6-40b9-9ec5-f32fa2e4ff02" TYPE="xfs"

# df
[root@mysourcehost ~]# df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        472M     0  472M   0% /dev
tmpfs           495M     0  495M   0% /dev/shm
tmpfs           495M   13M  482M   3% /run
tmpfs           495M     0  495M   0% /sys/fs/cgroup
/dev/xvda1      8.0G  837M  7.2G  11% /
tmpfs            99M     0   99M   0% /run/user/1000
tmpfs            99M     0   99M   0% /run/user/0
```
# parted
```
[root@mysourcehost ~]# parted -l
Model: Xen Virtual Block Device (xvd)
Disk /dev/xvda: 8590MB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  8590MB  8589MB  primary  xfs          boot
```

# AWS Stuff

a) In AWS - Make a snapshot of the machine.
b) Create a volume using the Snapshot id.

# Add the volume to the machine:
You should see two now.

```
[root@mysourcehost ~]# blkid
/dev/xvda1: UUID="6cd50e51-cfc6-40b9-9ec5-f32fa2e4ff02" TYPE="xfs"
/dev/xvdf1: UUID="6cd50e51-cfc6-40b9-9ec5-f32fa2e4ff02" TYPE="xfs"
```

```
[root@mysourcehost ~]# parted -l
Model: Xen Virtual Block Device (xvd)
Disk /dev/xvda: 8590MB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  8590MB  8589MB  primary  xfs          boot


Model: Xen Virtual Block Device (xvd)
Disk /dev/xvdf: 17.2GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  17.2GB  17.2GB  primary  xfs          boot
```

# We created a 17GB disk for the new os
   it is mounted as the second disk as /dev/xvdf1 in EC2

# Delete the partition on the second disk.

in our case the second disk is /dev/xvdf

```
parted /dev/xvdf --script rm 1
```

# Create a new partition table using the script command or through the interface

```
parted /dev/xvdf --script -- mklabel gpt  
parted -a optimal /dev/xvdf --script -- mkpart bbp 1MB 2MB
parted /dev/xvdf --script -- set 1 bios_grub on
parted -a optimal /dev/xvdf mkpart root xfs 2MB 33%
parted -a optimal /dev/xvdf mkpart swap xfs 33% 40%
parted -a optimal /dev/xvdf mkpart var xfs  40% 80%
parted -a optimal /dev/xvdf mkpart tmp xfs  80% 100%
```

# completion should look something likes this

```
[root@mysourcehost ~]# parted -l /dev/xvdf                            
Model: Xen Virtual Block Device (xvd)
Disk /dev/xvda: 8590MB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  8590MB  8589MB  primary  xfs          boot


Model: Xen Virtual Block Device (xvd)
Disk /dev/xvdf: 16.1GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name  Flags
 1      1049kB  2097kB  1049kB               bbp   bios_grub
 2      2097kB  5315MB  5313MB               root
 3      5315MB  6442MB  1127MB               swap
 4      6442MB  12.9GB  6442MB               var
 5      12.9GB  16.1GB  3220MB               tmp

```

# now format the file-systems

```
mkfs.xfs /dev/xvdf2
mkfs.swap /dev/xvdf3
mkfs.xfs /dev/xvdf4
mkfs.xfs /dev/xvdf5
```

# create mount points and mount

```
mkdir /mnt/myroot
mount /dev/xvdf2 /mnt/myroot
mkdir /mnt/myroot/tmp
mkdir /mnt/myroot/var
mount /dev/xvdf4 /mnt/myroot/var
mount /dev/xvdf5 /mnt/myroot/tmp
```

# mount and add a source disks to copy from

```
mkdir /mnt/mysource
mount /dev/xvdg1 /mnt/mysource
```

# this error may require you to rename the disk uuid


```
mount: wrong fs type, bad option, bad superblock on /dev/xvdg1,
       missing codepage or helper program, or other error

       In some cases useful info is found in syslog - try
       dmesg | tail or so.
```

```
Nov  6 01:54:16 mysourcehost kernel: XFS (xvdf5): Mounting V5 Filesystem
Nov  6 01:54:17 mysourcehost kernel: XFS (xvdf5): Ending clean mount
Nov  6 01:55:11 mysourcehost kernel: blkfront: xvdg: barrier or flush: disabled; persistent grants: disabled; indirect descriptors: enabled;
Nov  6 01:55:11 mysourcehost kernel: xvdg: xvdg1
Nov  6 01:56:41 mysourcehost kernel: XFS (xvdg1): Filesystem has duplicate UUID 6cd50e51-cfc6-40b9-9ec5-f32fa2e4ff02 - can't mount
```

# generate a random uuid for the second volume if needed

```
uuidgen #will generate a random uuid
[root@mysourcehost ~]# xfs_admin -U $(uuidgen) /dev/xvdg1
Clearing log and setting UUID
writing all SBs
```

# if you see an error you may need to run a aws_ami_howto_fix_duplicate_uuid

```
[root@mysourcehost ~]# xfs_repair -L /dev/xvdg1
Phase 1 - find and verify superblock...
Phase 2 - using internal log
        - zero log...
ALERT: The filesystem has valuable metadata changes in a log which is being
destroyed because the -L option was used.
        - scan filesystem freespace and inode maps...
agi unlinked bucket 10 is 2122 in ag 1 (inode=4196426)
sb_fdblocks 1880337, counted 1888529
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
disconnected inode 4196426, moving to lost+found
Phase 7 - verify and correct link counts...
Maximum metadata LSN (7:11849) is ahead of log (1:2).
Format log to cycle 10.
done
```

# after this a mount should work

```
mount /dev/xvdg1 /mnt/mysource
```


see https://github.com/zeekus/textfiles/blob/master/aws_ami_howto_fix_duplicate_uuid.md

# copy data from source os with rsync

```
 rsync -av /mnt/mysource/tmp/ /mnt/myroot/tmp/
 rsync -av /mnt/mysource/var/ /mnt/myroot/var/
 rsync -av /mnt/mysource/ /mnt/myroot/ --exclude=var --exclude=tmp --exclude=/mnt/myroot
 chmod 755 /mnt/myroot/home
 chmod 1777 /mnt/myroot/tmp
 chmod 755 /mnt/myroot/var
```

# after copying the data remove the source disks

```
umount /mnt/mysource
```

# mount live kernel subsystems so we can run grub without having to jump around

```
mkdir -p /mnt/myroot/proc /mnt/myroot/dev /mnt/myroot/sys
mount -o bind /proc /mnt/myroot/proc
mount -o bind /sys /mnt/myroot/sys
mount -o bind /dev /mnt/myroot/dev
mount -o bind /dev/shm /mnt/myroot/dev/shm
```

# chroot to new File-system

```
chroot /mnt/myroot
/bin/bash
```

# generate new fstab

```
blkid >> /etc/fstab
vi /etc/fstab
```

# should have something like this

```
#
# /etc/fstab
# Created by anaconda on Wed Apr 22 09:05:25 2020
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=e893b495-27e7-4f1f-83af-f68f8344974a / xfs defaults 0 0
UUID=b3836bbd-0d0c-4afd-9b72-e8ea5699251d /var xfs defaults 0 0
UUID=c3d42a89-72be-44d3-a974-9fd4ee98074d /tmp xfs defaults 0 0
#/dev/xvdf1: PARTLABEL="bbp" PARTUUID="e5a85641-c1da-4a8d-9e9c-df7823702208"
#/dev/xvdf2: UUID="e893b495-27e7-4f1f-83af-f68f8344974a" TYPE="xfs" PARTLABEL="root" PARTUUID="d86d1843-b737-47f2-aa9d-a0f71611eb96"
#/dev/xvdf3: PARTLABEL="swap" PARTUUID="63738e4d-4b51-4056-a8aa-2b4b74ff7c70"
#/dev/xvdf4: UUID="b3836bbd-0d0c-4afd-9b72-e8ea5699251d" TYPE="xfs" PARTLABEL="var" PARTUUID="17efba30-d1ef-4a61-a66c-9c3a09ac843c"
#/dev/xvdf5: UUID="c3d42a89-72be-44d3-a974-9fd4ee98074d" TYPE="xfs" PARTLABEL="tmp" PARTUUID="d1dca58a-f95c-4497-8775-dc551b0cff2b"

```

#find first partitioning

```
[root@ip-172-31-43-87 EFI]# blkid  | grep -i root
/dev/xvdf2: UUID="13ddc01c-7085-4ef7-9419-acc9d3419a85" TYPE="xfs" PARTLABEL="root" PARTUUID="33c8962a-d042-47fb-adae-df23322e76d1"
```

# verify the kernel running and check UUID mapping


```
[root@mysource]# awk '/\s*kernel/{print}' /boot/grub/menu.lst
	kernel /boot/vmlinuz-3.10.0-1127.el7.x86_64 ro root=UUID=6cd50e51-cfc6-40b9-9ec5-f32fa2e4ff02 console=hvc0 LANG=en_US.UTF-8
```

# *DANGER* manually fix grub entry if needed

*note we kept the root disk the same number /dev/xvda2*

```
sed -i 's/6cd50e51-cfc6-40b9-9ec5-f32fa2e4ff02/13ddc01c-7085-4ef7-9419-acc9d3419a85/g' /boot/grub/grub.conf
sed -i 's/6cd50e51-cfc6-40b9-9ec5-f32fa2e4ff02/13ddc01c-7085-4ef7-9419-acc9d3419a85/g' /boot/grub2/grub.cfg
```

# run make grub install

```
[root@mysourcehost /]# grub2-install /dev/xvdf
Installing for i386-pc platform.
Installation finished. No error reported.
```


# don't run grub2-mkconfig if you have your files available.

*doing this can make a mess of the grub config because os-prober will probe the wrong disks*

# reset the autolabel on selinux or the host may not become available

```
touch /mnt/myroot/.autorelabel
```

# unmount file systems and reboot

```
sync && umount /mnt/myroot/dev/shm
sync && umount /mnt/myroot/dev
sync && umount /mnt/myroot/proc
sync && umount /mnt/myroot/sys
sync && umount /mnt/myroot/var
sync && umount /mnt/myroot/tmp
sync && umount /mnt/myroot
```


source: https://www.daniloaz.com/en/partitioning-and-resizing-the-ebs-root-volume-of-an-aws-ec2-instance/

ref: Dean Cloud Support Engineer from AWS: https://www.youtube.com/watch?v=QiMpJi2YWxA
