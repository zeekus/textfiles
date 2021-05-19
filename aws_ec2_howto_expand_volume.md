# How to expand an XFS volume on Linux machine.
**note -- assumption this is not a LVM volume**

# 1 create a recovery point in time.
make a snapshot of the volume you plan on expanding.

# 2  expand the volume in Ec2

https://aws.amazon.com/premiumsupport/knowledge-center/expand-root-ebs-linux/

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/recognize-expanded-volume-linux.html

# 3 Verify the volume expanded

**note we expanded nvme1n1**

```
[root@server1p ~]# lsblk
NAME                 MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
nvme0n1              259:2    0  30G  0 disk
├─nvme0n1p1          259:3    0   1G  0 part /boot
├─nvme0n1p2          259:4    0  10G  0 part
│ ├─Data-home        253:2    0   5G  0 lvm  /home
│ └─Data-var_www     253:3    0   5G  0 lvm  /var/www
└─nvme0n1p3          259:5    0  19G  0 part
  ├─OS-root          253:0    0   4G  0 lvm  /
  ├─OS-swap          253:1    0   2G  0 lvm  [SWAP]
  ├─OS-tmp           253:4    0   3G  0 lvm  /tmp
  ├─OS-var           253:5    0   2G  0 lvm  /var
  ├─OS-var_tmp       253:6    0   2G  0 lvm  /var/tmp
  ├─OS-var_log       253:7    0   4G  0 lvm  /var/log
  └─OS-var_log_audit 253:8    0   2G  0 lvm  /var/log/audit
nvme1n1              259:0    0  50G  0 disk
└─nvme1n1p1          259:1    0  30G  0 part /var/atlassian
```

# 4  Grow the partiton with 'growpart' if you are using XFS

```
yum install cloud-utils-growpart

[root@server1p ~]# growpart /dev/nvme1n1 1
CHANGED: partition=1 start=2048 old: size=62912512 end=62914560 new: size=104855519 end=104857567
```

# 5 grow the expnand the XFS volume using 'xfs_growfs'

```

[root@server1p ~]# xfs_growfs -d /var/atlassian
meta-data=/dev/nvme1n1p1         isize=512    agcount=4, agsize=1966016 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=7864064, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=3839, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 7864064 to 13106939
```





Ref: https://hackernoon.com/tutorial-how-to-extend-aws-ebs-volumes-with-no-downtime-ec7d9e82426e

Other sources:
Ummount and expand: 
ref: https://www.cloudinsidr.com/content/how-to-expand-an-xfs-ebs-volume-on-aws-ec2/