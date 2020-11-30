# Reload the rules:
*very important after changes are made*
```
firewall-cmd --reload
```
# Get a list of all the zones defined:

```
firewall-cmd --list-all-zones
```

# Get a list of the active rules *better than above*
```
[root@myhost ~]# firewall-cmd --get-active-zones
public
  interfaces: eth0
 ```

# List the rules from the public zone:
```
[root@myhost ~]# firewall-cmd --list-all --zone=public
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
[root@myhost ~]# firewall-cmd --zone=public --permanent --add-port=25/tcp
success
firewall-cmd --reload
success
```

# Manually remove port 25:
```
[root@myhost ~]# firewall-cmd --zone=public --permanent --remove-port=25/tcp
success
firewall-cmd --reload
success
```
# List services allowed:
```
[root@myhost ~]# firewall-cmd --list-services
```

# manually remove service dhcpv6-client
```
firewall-cmd --zone=public --permanent --remove-service=dhcpv6-client
success
firewall-cmd --reload
success
```

# Files that are modified with firewalld: Centos8
file: /etc/firewalld/firewalld.conf
zone files: /etc/firewalld/zones
```
[root@myhost zones]# ls
block.xml  dmz.xml  drop.xml  external.xml  home.xml  internal.xml  public.xml  public.xml.old  trusted.xml  work.xml
[root@myhost zones]# pwd
```

# Manaully Reset firewall to defaults installation files when things get FUBAR:
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
