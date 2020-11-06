
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

# Delete the partition on the second disk.


```
parted /dev/xvdf
rm 1
quit
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

did the grub install this way

```
[root@mysourcehost ~]# rm /mnt/myroot/boot/grub/grub.conf
rm: remove regular file ‘/mnt/myroot/boot/grub/grub.conf’? y
[root@mysourcehost ~]# grub2-mkconfig -o /mnt/myroot/boot/grub/grub.conf
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-1127.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-1127.el7.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-cab9605edaa5484da7c2f02b8fd10762
Found initrd image: /boot/initramfs-0-rescue-cab9605edaa5484da7c2f02b8fd10762.img
Found CentOS Linux release 7.8.2003 (Core) on /dev/xvdf2
done
[root@mysourcehost ~]# grub2-mkconfig -o /mnt/myroot/boot/grub/grub.conf^C
[root@mysourcehost ~]# grub2-install --target=i386-pc --directory=/mnt/myroot/usr/lib/grub/i386-pc --recheck --boot-directory=/mnt/myroot/boot /dev/xvdf
Installing for i386-pc platform.
Installation finished. No error reported.
```


# mount live kernel subsystems so we can run grub without having to jump around

```
mkdir -p /mnt/myroot/proc /mnt/myroot/dev /mnt/myroot/sys
mount -o bind /proc /mnt/myroot/proc
mount -o bind /dev /mnt/myroot/dev
mount -o bind /sys /mnt/myroot/sys
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
[root@mysourcehost grub]# blkid | grep -i xvdf1
/dev/xvdf1: PARTLABEL="bbp" PARTUUID="e5a85641-c1da-4a8d-9e9c-df7823702208"
```

# run make grub using the uuid flag and point to first partition for this os

```
[root@mysourcehost grub]# grub2-mkconfig -o /boot/grub/grub.conf uuid=e5a85641-c1da-4a8d-9e9c-df7823702208
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-1127.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-1127.el7.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-cab9605edaa5484da7c2f02b8fd10762
Found initrd image: /boot/initramfs-0-rescue-cab9605edaa5484da7c2f02b8fd10762.img
Found CentOS Linux release 7.8.2003 (Core) on /dev/xvdg1
done

```

# run make grub install

```
[root@mysourcehost /]# grub2-install /dev/xvdf
Installing for i386-pc platform.
Installation finished. No error reported.
```

# verify grub.conf file was generated correct

on centos7 mine was pointing to the wrong uuid and drive.

Here is the output from cat -n grub.conf

```
126  ### BEGIN /etc/grub.d/30_os-prober ###
 127  menuentry 'CentOS Linux release 7.8.2003 (Core) (on /dev/xvdg1)' --class gnu-linux --class gnu --class os $menuentry_id_option 'osprober-gnulinux-simple-3c285cd2-de98-46c5-86f3-2df58f18e5c7' {
 128          insmod part_msdos
 129          insmod xfs
 130          if [ x$feature_platform_search_hint = xy ]; then
 131            search --no-floppy --fs-uuid --set=root  3c285cd2-de98-46c5-86f3-2df58f18e5c7
 132          else
 133            search --no-floppy --fs-uuid --set=root 3c285cd2-de98-46c5-86f3-2df58f18e5c7
 134          fi
 135          linux /boot/vmlinuz-3.10.0-1127.el7.x86_64 ro root=UUID=6cd50e51-cfc6-40b9-9ec5-f32fa2e4ff02 console=hvc0 LANG=en_US.UTF-8
 136          initrd /boot/initramfs-3.10.0-1127.el7.x86_64.img
 137  }
 138  submenu 'Advanced options for CentOS Linux release 7.8.2003 (Core) (on /dev/xvdg1)' $menuentry_id_option 'osprober-gnulinux-advanced-3c285cd2-de98-46c5-86f3-2df58f18e5c7' {
 139          menuentry 'CentOS Linux 7 (3.10.0-1127.el7.x86_64) (on /dev/xvdg1)' --class gnu-linux --class gnu --class os $menuentry_id_option 'osprober-gnulinux-/boot/vmlinuz-3.10.0-1127.el7.x86_64--3c285cd2-de98-46c5-86f3-2df58f18e5c7' {
 140                  insmod part_msdos
 141                  insmod xfs
 142                  if [ x$feature_platform_search_hint = xy ]; then
 143                    search --no-floppy --fs-uuid --set=root  3c285cd2-de98-46c5-86f3-2df58f18e5c7
 144                  else
 145                    search --no-floppy --fs-uuid --set=root 3c285cd2-de98-46c5-86f3-2df58f18e5c7
 146                  fi
 147                  linux /boot/vmlinuz-3.10.0-1127.el7.x86_64 ro root=UUID=6cd50e51-cfc6-40b9-9ec5-f32fa2e4ff02 console=hvc0 LANG=en_US.UTF-8
 148                  initrd /boot/initramfs-3.10.0-1127.el7.x86_64.img
 149          }
 150  }
```

# make a backup of the grub.configuration

```
cd /boot/grub
cp grub.conf grub.conf.bak
```

# fix the grub.conf and rerun grub Installing

The root file system has this uuid on our system
```
[root@mysourcehost ~]# blkid | grep -i root
/dev/xvdf2: UUID="e893b495-27e7-4f1f-83af-f68f8344974a" TYPE="xfs" PARTLABEL="root" PARTUUID="d86d1843-b737-47f2-aa9d-a0f71611eb96"
```

Sed can be used to change it easily

```
[root@mysourcehost grub]# sed -i 's/e5a85641-c1da-4a8d-9e9c-df7823702208/d86d1843-b737-47f2-aa9d-a0f71611eb96/g' grub.conf
```

# do the same for the drive

```
sed -i 's/xvdg1/xvda1/g' grub.conf
```

# change to root path on grub.cfg

```
cd /boot/grub2
sed -i 's/e5a85641-c1da-4a8d-9e9c-df7823702208/d86d1843-b737-47f2-aa9d-a0f71611eb96/g' grub.cfg
```

# redo the grub Installing

```
[root@mysourcehost grub]# grub2-install /dev/xvdg
Installing for i386-pc platform.
Installation finished. No error reported.
```

# exit out of chroot

```
exit
```


# unmount file systems and reboot

```
sync && umount /mnt/myroot/dev
sync && umount /mnt/myroot/proc
sync && umount /mnt/myroot/sys
sync && umount /mnt/myroot/var
sync && umount /mnt/myroot/tmp
sync && umount /mnt/myroot
```


source: https://www.daniloaz.com/en/partitioning-and-resizing-the-ebs-root-volume-of-an-aws-ec2-instance/
