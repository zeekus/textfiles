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
adcli - mostly widely used in Centos7, Centos8
realmmd -
authconfig - 
```

# configuration files that control domain registration need to be created

# Main: #file: /etc/kerb5.conf

The '/etc/kerb5.conf' gets created after joining the domain. 
Note the renewal will fail if the DNS is setup oddly.


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

# /etc/resolv.conf

Make sure the DNS is setup to only search your domain.
If you use a secondary domain like AWS, this could cause renewals to fail. 

# verifying that adcli is connected/setup

```
adcli info example.net
```

# verifiying if the realm is connected

```
realm list
```

# refreshes kerbose key on Centos6/7

```
kinit -R 
```


# refreshes kerbose key on Centos8
```
kinit -R -p zeekus@EXAMPLE.NET
```

# if you see this, it may need a reboot or a refresh failed. 

```
[root@myserver ~]# klist
klist: No credentials cache found (filename: /tmp/krb5cc_0)
[root@myserver ~]# klist -l
Principal name                 Cache name
--------------                 ----------

```

# we should see this if things are setup right.

```

[zeekus@myserver0p ~]$ kmyserver
Ticket cache: FILE:/tmp/krb5cc_1382418527_HGXGh1
Default principal: zeekus@EXAMPLE.NET

Valid starting       Expires              Service principal
12/08/2020 17:20:34  12/09/2020 03:20:34  krbtgt/EXAMPLE.NET@EXAMPLE.NET
        renew until 12/15/2020 17:20:34
```


# a manual kinit may help

```
[zeekus@myhost1 ~]$ kinit
Password for ted.knab@CHESAPEAKEBAY.NET:
[zeekus@myhost1 ~]$ kinit -R
kinit: KDC can't fulfill requested option while renewing credentials
```

```
[zeekus@myhost1] ~]$ klist
Ticket cache: KEYRING:persistent:1382418527:krb_ccache_I2xVwrl
Default principal: zeekus@EXAMPLE.NET

Valid starting       Expires              Service principal
12/08/2020 14:46:24  12/09/2020 00:46:24  krbtgt/example.NET@example.NET
        renew until 12/15/2020 14:46:13
```


# clean up old kerbose stuff to retry

```
#!/bin/bash
#filename: cleanup_kerbose.sh
echo "clean up kerbose stuff"
cleanup="/root/.ssh/known_hosts /etc/krb5.conf.d/kcm_default_ccache /etc/krb5.keytab"
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


# manually re-joining a domain with adcli

```
adcli join  --domain-controller=dce.example.net --domain-ou='ou=Computers,ou=Linux,dc=example,dc=net' --login-user='zeekus'
```

# manually removing computer from AD

```
adcli delete-computer myserver1p --domain-controller=dcf.example.net --login-user='zeekus'
```