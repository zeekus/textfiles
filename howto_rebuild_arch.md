Quick rebuild plan for Arch 



# 1. install using the text installer 

```
  archinstall
  -set timezone
  -set repo source 
```

  *extra packages to add in the installer*
  ```
  vim nmcli NetworkManager dhclient
  ```  

# backup plan if we forget to the add the network stuff

```



```

# 2. Nvidia and xterm are needed: 

```
sudo pacman -S networkmanager nmcli nvidia xterm nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
```

# 3. Wine stuff: 

```
sudo pacman -S --needed wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader lutris 
```

# 4. install accessories.

```
pacman -S man jruby firefox chromium xfce4 lightdm lightdm-gtk-greeter mumble discord xorg python-pip code espeak-ng python-opencv

pip install virtualenv pyautogui

```



# 5. setup nvidia hooks for cpio and initram disk

```
vim /etc/pacman.d/hooks/nvidia.hook
```

```
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg;do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
```

# 6. desktop setup

```
systemctl start lightdm
systemctl enable lightdm
```
