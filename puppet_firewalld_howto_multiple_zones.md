# You can use Yaml to manage multiple zones.
*last updated 11/18/2020* 

It is a bit tricky.

# Note puppet needs a lot of ports open to work properly.

The ports needed are documented here: https://puppet.com/docs/pe/2019.8/system_configuration.html

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
  puppetmaster: #wording changing in 2019.8.3
    ensure: present
    service: puppetmaster
    zone: public
firewalld::ports:
  port_4443:
    ensure: present
    port: 4433
    zone: public
  port_8140:
    ensure: present
    port: 8140
    zone: public
  port_8142:
    ensure: present
    port: 8142
    zone: public
  port_8443:
    ensure: present
    port: 8443
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
  services:  nrpe  ssh
  ports: 4433/tcp 8140/tcp 8142/tcp 
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
  services:  dhcpv6-client http https ssh puppetmaster
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks: router-advertisement
  rich rules:
```



