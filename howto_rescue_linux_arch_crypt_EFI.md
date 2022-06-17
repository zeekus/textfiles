Problem: recovering an encrypted filesystem after the boot partiton becomes corrupt on arch.

After an upgrade we see this:

```
Reboot gives me this grub error:

Loading Linux linux ...
error: file '/vmlinuz-linux' not found
Loading initial ramdisk ...
error: you need to laod the kernel first.
```

Solution: Put Arch or another distro on a usb stick.


```
sudo dd \
  if=manjaro-mate-21.2.5-minimal-220314-linux515.iso \
  bs=4M \
  oflag=sync \
  of=/dev/sdb \
  status=progress
```

Fix the boot partion.


## Disk rescue using arch installer

```
[root@archiso]# lsblk

sda (usb)
 |-sda1
 |-sda2 
nvme0n1 (SSD) 
 |-nvme0n1p1
 |-nvme0n1p2
 |-nvme0n1p3
```

# make a mount point for the os to be rescued *staging area*
```
mkdir /mnt/arch
```
# decrypt crypt setup and put in device /dev/mappper/root

```
cryptsetup open /dev/nvme0n1p2 root
```

#mount root to staging area
```
mount /dev/mapper/root /mnt/arch/
```
[root@archiso /mnt/arch # arch-chroot /mnt/arch

#mount boot partition

```
mount /dev/nvme0n1p1 /mnt/arch/boot
```

#(optional) decrypt crypt home and setup the device if needed. 
```
cryptsetup open /dev/nvme0n1p3 home
mount /dev/mapper/home /mnt/arch/home
```



[root@archiso /] grub-install --efi-directory=/boot/EFI  --bootloader-id=grub /dev/nvme0n1 
Installing for x86_64-efi platform
Installation finished. No error reported.

Reboot gives me this grub error:

Loading Linux linux ...
error: file '/vmlinuz-linux' not found
Loading initial ramdisk ...
error: you need to laod the kernel first.

Press any key to continue...

Ran 'pacman -S linux' followed by another 
[root@archiso /] grub-install --efi-directory=/boot/EFI  --bootloader-id=grub /dev/nvme0n1 
to fix