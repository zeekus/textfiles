# WSL - Windows Subsystem for Linux

# Summary

Getting Debian to run on Windows is easy.
However, the /etc/resolv.conf will get overwritten by a default upon every start.
Here is a work around that uses the global .wslconfig to fix it.

```
C:> wsl --shutdown

cd \\Users\myuser

edit .wslconfig
```

```
# This file was generated from the .wsconfig stored in \\Users\myuser\.wsconfig
[network]
generateResolvConf = false
nameserver 10.16.48.15
nameserver 8.8.8.8  
```

ref: https://renenyffenegger.ch/notes/Linux/fhs/etc/wsl_conf
