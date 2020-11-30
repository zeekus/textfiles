# You can use Yaml to manage multiple zones, but the firewalld configuration has some limitions.

*Limitation: it seems you can't put multiple zones in the 'firewalld::services' area. But, 'rich_rules' can provide a work around. 

*last updated 11/30/2020* 

It is a bit tricky.

# Note puppet needs a lot of ports open to work properly.

The ports needed are documented here: https://puppet.com/docs/pe/2019.8/system_configuration.html

Here is a working example.

# 2 zones
  * public
  * monitoring for Nagios 


# YAML

```
#basic firewall rules
#file: common.yaml
#two zones default zone has interface attached to it
#secondary zone is monitoring for nagios nrpe/ssh connections. 
firewalld::ensure: present
# I found services can only be attached to one zone using the firewalld yaml. Not sure why. 
#When I tried assigning a 'nrpe' to 'zone: monitoring' nothing happened, so I used rich rules.  
firewalld::services:
  http:
    ensure: present
    service: http
    zone: public
  ssh_public: 
    ensure: present
    service: ssh
    zone: public
firewalld::zones:
  public:
    target: default
    ensure: present
    interfaces:
       - eth0
    purge_ports: true
    purge_rich_rules: true
    purge_services: true
    icmp_blocks: router-advertisement
  monitoring: 
    target: '%%REJECT%%'
    ensure: present
    sources: 10.128.0.13/32
    icmp_blocks: echo-reply

firewalld::rich_rules:
   'Accept SSH from nagios':
      ensure: present
      zone:  monitoring
      source: '10.128.0.13/32'
      service: 'ssh'
      action: 'accept'
   'Accept NRPE from nagios':
      ensure: present
      zone: monitoring
      source: '10.128.0.13/32'
      service: 'nrpe'
      action: 'accept'
```

*Setting the interface on two or more zones seems to break firewalld implementations with puppet.*
related source: https://serverfault.com/questions/654097/can-multiple-firewalld-zones-be-active-at-any-given-time


# How to verify the firewalld rules

*list your active zones*

```
[root@myhost ~]# firewall-cmd --get-active-zones
monitoring
  sources: 10.128.0.13/32
public
  interfaces: eth0
[root@ssh1p ~]# firewall-cmd --get-active-zones
monitoring
  sources: 10.128.0.13/32
public
  interfaces: eth0
```

*check on your 'monitoring' zone*

```
[root@myhost ]# firewall-cmd --zone=monitoring --list-all
monitoring (active)
  target: %%REJECT%%
  icmp-block-inversion: no
  interfaces:
  sources: 10.128.0.13/32
  services:
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks: echo-reply
  rich rules:
        rule family="ipv4" source address="10.128.0.13/32" service name="ssh" accept
        rule family="ipv4" source address="10.128.0.13/32" service name="nrpe" accept
```

*check your 'public zone'. Note this zone is the default/required zone* 
```
[root@myhost ]# firewall-cmd --zone=public --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0
  sources:
  services: http ssh
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks: router-advertisement
  rich rules:
```

# Basic testing

*remove 'monitoring zone' and test*

```
[root@myhost ~]# firewall-cmd --permanent --delete-zone=monitoring
success
[root@myhost ~]# firewall-cmd --reload
success
[root@myhost ~]# firewall-cmd --zone=monitoring --list-all
Error: INVALID_ZONE: monitoring
```

*remove a rule in from the services area to verify puppet puts it back* 

```
firewall-cmd --zone=public --remove-service=http --permanent
firewall-cmd --reload
```

*verify puppet puts them back in*

```
puppet agent -tv
```
