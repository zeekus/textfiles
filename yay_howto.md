
# What is YAY ? 

Yet another Yogurt

# how to install yay

```
git clone httsp://aur.archlinux.org/yay.git  
cd yay
makepkg -si
```
or

```
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
```

# install a yay package
yay -S <package>

# remove a yay package

yay -R <package>

# remove a yay package and deps

yay -Rns <package>

# upgrade system

```
yay -Syu

yay # this does the same thing
```