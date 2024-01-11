# set hostname

```
hostnamectl set-hostname myserver.mydomain.com
```

# look at the devices 

```
nmcli device show 
nmcli device show eth0
```

# use dchp address for both ipv4 and ipv6

```
nmcli device modify eth0 ipv4.method auto
nmcli device modify eth0 ipv6.method auto
```

# enable the connection

```
nmcli con up "Connection Name"
```

or 

```
nmcli con up eth0 
```
