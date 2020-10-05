# You can use Yaml to manage multiple zones.

It is a bit tricky.

Here is a working example.

# 2 zones
  * public
  * monitoring for Nagios 

# YAML

```
firewalld::ensure: present
firewalld::services:
  http:
    ensure: present
    service: http
    zone: public
  nrpe:
    ensure: present
    service: nrpe
    zone: monitoring
  ssh_public: 
    ensure: present
    service: ssh
    zone: public
  ssh_monitoring: 
    ensure: present
    service: ssh
    zone: monitoring
  cockpit:
    ensure: present
    service: cockpit
    zone: public
firewalld::zones:
  public:
    target: '%%REJECT%%'
    ensure: present
    purge_ports: true
    interfaces: eth0
    purge_rich_rules: true
    purge_services: true
    icmp_blocks: router-advertisement
  monitoring: 
    target: default 
    interfaces: eth0
    sources: 10.128.0.13/32
    icmp_blocks: echo-reply
```

How to verify.

```
[root@myhost ]# firewall-cmd --zone=monitoring --list-all
monitoring (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0
  sources: 10.128.0.13/32
  services: nrpe ssh
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks: echo-reply
  rich rules:

[root@myhost ]# firewall-cmd --zone=public --list-all
public
  target: %%REJECT%%
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit http ssh
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks: router-advertisement
  rich rules:
```