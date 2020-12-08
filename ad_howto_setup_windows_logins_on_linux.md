# Draft started 8/14/2020

# How to setup Linux to connect to a Windows domain

Linux can use AD as a authentication method. There are multiple tools that can be used to this.


## steps
```
  1 join the domain - before you can use Windows authentication you need to join your Linux box to a Windows or Samba domain controller. 
  2 setup sssd and oddjobs - for login and home directory managment. 
```


# Linux tools to 'join a domain'

```
adcli - mostly widely used
realmmd -
authconfig - 
```

# configuration files that control domain registration create

These should appear after a Linux host is joined to a domain. 


```
#file: /etc/kerb5.conf 
# To opt out of the system crypto-policies configuration of krb5, remove the
# symlink at /etc/krb5.conf.d/crypto-policies which will not be recreated.
#includedir /etc/krb5.conf.d/

[appdefaults]
  pam = {
        validate =true
        ccache_dir=/var/tmp
        EXAMPLE.NET = {
          debug=true
          keytab=FILE:/etc/krb5.keytab
        }
    }
[logging]
    default = FILE:/var/log/krb5libs.log
    kdc = FILE:/var/log/krb5kdc.log
    admin_server = FILE:/var/log/kadmind.log

[libdefaults]
    dns_lookup_realm = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true
    rdns = false
    pkinit_anchors = FILE:/etc/pki/tls/certs/ca-bundle.crt
    spake_preauth_groups = edwards25519
    default_ccache_name = KEYRING:persistent:%{uid}
    default_realm = EXAMPLE.NET
#    default_realm = EXAMPLE.COM

[realms]
 EXAMPLE.NET = {
}
# EXAMPLE.COM = {
#     kdc = kerberos.example.com
#     admin_server = kerberos.example.com
# }
#
[domain_realm]
 .EXAMPLE.net = EXAMPLE.NET
 EXAMPLE.net = EXAMPLE.NET

```

# verifying that adcli is connected/setup

```
adcli info example.net
```

# verifiying if the realm is connected

```
realm list
```

# refreshink a kerbose key
```
kinit -R
```

# if you see this, it may need a reboot

```
[root@myserver ~]# klist
klist: No credentials cache found (filename: /tmp/krb5cc_0)
[root@myserver ~]# klist -l
Principal name                 Cache name
--------------                 ----------

```


# clean up old kerbose stuff to retry

```
#!/bin/bash
#filename: cleanup_kerbose.sh
echo "clean up kerbose stuff"
cleanup="/root/.ssh/known_hosts /etc/krb5.conf.d/kcm_default_ccache /etc/krb5.keytab /etc/sssd/sssd.conf"
for myfile in $cleanup
  do
    if [ -f "$myfile" ]; then
      echo removing $myfile
      rm -f $myfile
    else
      echo "didn't find $myfile"
    fi
  done
```

# clean up ad entry for host if it exists. 

# re-joining a domain with adcli

```
adcli join  --domain-controller=dce.example.net --domain-ou='ou=Computers,ou=Linux,dc=example,dc=net' --login-user='zeekus'
```