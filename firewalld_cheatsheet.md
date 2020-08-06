# Reload the rules:
firewall-cmd --reload

# Get a list of the active rules:
```
[root@lpe2d ~]# firewall-cmd --get-active-zones
public
  interfaces: eth0
 ```

# List the rules from the public zone:
```
[root@lpe2d ~]# firewall-cmd --list-all --zone=public
public (active)
  target: %%REJECT%%
  icmp-block-inversion: no
  interfaces: eth0
  sources:
  services: http nrpe ssh
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks: router-advertisement
  rich rules:
```
# Manually allow port 25:
```
[root@lpe2d ~]# firewall-cmd --zone=public --permanent --add-port=25/tcp
success
```

# Manually remove port 25:
```
[root@lpe2d ~]# firewall-cmd --zone=public --permanent --remove-port=25/tcp
success
```
# List services allowed:
```
[root@lpe2d ~]# firewall-cmd --list-services
```

# manually remove service dhcpv6-client
```
firewall-cmd --zone=public --permanent --remove-service=dhcpv6-client
```

# Check configuration files: Centos8
file: /etc/firewalld/firewalld.conf
zone files: /etc/firewalld/zones
```
[root@lpe2d zones]# ls
block.xml  dmz.xml  drop.xml  external.xml  home.xml  internal.xml  public.xml  public.xml.old  trusted.xml  work.xml
[root@lpe2d zones]# pwd
```


# Reset firewall to defaults installation files:
```
#!/bin/bash
#filename: reset_firewalld_to_default.sh
#description: removes any firewall customization and reverts to OS version. 
rm -f /etc/firewalld/zones/*
cp /usr/lib/firewalld/zones/* /etc/firewalld/zones/.
firewall-cmd --reload
echo "default firewall applied"
systemctl status firewalld
```
