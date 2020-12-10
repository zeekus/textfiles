
## Troubleshooting domain joins from linux:


The 'canary' with AD and Linux is 'klist'. If klist stops displaying stuff, you probably have some type of issue.
It may take a while for the logins to come to a scretching halt, but it will come. ;-)

# list the keytab info

*Note this only works: when things are setup right and the a kerbose ticket hasn't exired.* 

```
klist -kte

[root@myserver_example ~]# klist -kte
Keytab name: FILE:/etc/krb5.keytab
KVNO Timestamp         Principal
---- ----------------- --------------------------------------------------------
   2 12/09/15 11:14:14 host/myserver_example.us-east.aws.example.net@example.NET (des-cbc-crc)
   2 12/09/15 11:14:14 host/myserver_example.us-east.aws.example.net@example.NET (des-cbc-md5)
   2 12/09/15 11:14:14 host/myserver_example.us-east.aws.example.net@example.NET (aes128-cts-hmac-sha1-96)
   2 12/09/15 11:14:14 host/myserver_example.us-east.aws.example.net@example.NET (aes256-cts-hmac-sha1-96)
   2 12/09/15 11:14:14 host/myserver_example.us-east.aws.example.net@example.NET (arcfour-hmac)
   2 12/09/15 11:14:14 host/myserver_example@example.NET (des-cbc-crc)
   2 12/09/15 11:14:14 host/myserver_example@example.NET (des-cbc-md5)
   2 12/09/15 11:14:14 host/myserver_example@example.NET (aes128-cts-hmac-sha1-96)
   2 12/09/15 11:14:14 host/myserver_example@example.NET (aes256-cts-hmac-sha1-96)
   2 12/09/15 11:14:14 host/myserver_example@example.NET (arcfour-hmac)
   2 12/09/15 11:14:14 myserver_example$@example.NET (des-cbc-crc)
   2 12/09/15 11:14:14 myserver_example$@example.NET (des-cbc-md5)
   2 12/09/15 11:14:14 myserver_example$@example.NET (aes128-cts-hmac-sha1-96)
   2 12/09/15 11:14:14 myserver_example$@example.NET (aes256-cts-hmac-sha1-96)
   2 12/09/15 11:14:14 myserver_example$@example.NET (arcfour-hmac)
```

# looking at the cache files

*The net command is found in 'samba-common-tools'*


```
[root@myserver ~]# rpm -q --whatprovides /usr/bin/net
samba-common-tools-4.10.16-7.el7_9.x86_64
```

```
[root@myserver ~]# net cache list |head
Key: IDMAP/SID2XID/S-1-5-21-780216973-25257766-102967255-13433   Timeout: Tue Aug 18 13:26:58 2020       Value: 16777234:G
Key: IDMAP/GID2SID/16777250      Timeout: Tue Aug 18 13:26:58 2020       Value: S-1-5-21-780216973-25257766-102967255-11524
Key: IDMAP/SID2XID/S-1-5-21-780216973-25257766-102967255-15552   Timeout: Tue Aug 18 13:26:58 2020       Value: 16777270:G
Key: IDMAP/SID2XID/S-1-5-21-780216973-25257766-102967255-16536   Timeout: Tue Aug 18 13:26:58 2020       Value: 16777297:G
Key: IDMAP/GID2SID/16777311      Timeout: Tue Aug 18 13:26:58 2020       Value: S-1-5-21-780216973-25257766-102967255-12050
```

# If there is nothing in 'klist' you will need to manually rejoin the DOMAIN.  *note the Caps ON for DOMAIN*

```
[root@myserver_example ~]# kinit -V my_user@EXAMPLE.NET
Password for my_user@EXAMPLE.NET:
```
*After 'klist' and 'net' should display the info* 

```
[root@myserver_example ~]# net cache list |head
Key: NBT/DCE.example.NET#20        Timeout: 08:37:01       Value: 10.128.4.10:0
Key: NBT/DCF.example.NET#20        Timeout: 08:37:01       Value: 10.128.4.140:0
Key: SAF/DOMAIN/CIMS     Timeout: 08:41:01       Value: dce.example.net
Key: SAF/DOMAIN/example.NET        Timeout: 08:41:01       Value: dce.example.net
Key: IDMAP/SID2XID/S-1-5-21-780216973-25257766-102967255-13433   Timeout: Tue Aug 18 13:26:58 2020       Value: 16777234:G
```

# join with a clear pass with a special chacter will generate a parser error

```
clearpass.txt = "!21likespecialCHARACTERS!!!!!!!!"

[root@myserver_example ~]# cat clearpass.txt | iconv -f UTF-8 -t CP1252| adcli join  --domain-controller=dce.example.net --domain-ou='ou=Computers,ou=Linux,dc=example,dc=net' --login-user='my_user' --stdin-password
adcli: couldn't connect to example.net domain: Couldn't authenticate as: my_user@example.NET: Preauthentication failed
[note preauthentication failed means that the parser did not like the special characters in the password]
source: https://bugs.freedesktop.org/show_bug.cgi?id=99676
```

# joining a domain with adcli 

``
[root@myserver_example ~]# adcli join  --domain-controller=dce.example.net --domain-ou='ou=Computers,ou=Linux,dc=example,dc=net' --login-user='my_user'
Password for my_user@EXAMPLE.NET:
adcli: joining domain example.net failed: The computer account myserver_example already exists, but is not in the desired organizational unit.
``

# files that are important

When adcli and realmd join a domain, they create a /etc/krb5.conf. Sometimes this needs to be tweaked to function properly.

For example, both seem to leave out somethings that can cause 'kinit -Rv' from not working.
This may be an indication that some parts of the /etc/krb5.conf are missing.

```
[root@myserver ~]# kinit -R
kinit: Configuration file does not specify default realm when parsing name root
```

# file /etc/krb5.conf for Centos8 

```
#file: /etc/krb5.conf
#description: needed for kerberos key restores to work
#source: centos8
#main diff for centos8 libdefaults

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
 default_realm = EXAMPLE.NET
 default_ccache_name = KEYRING:persistent:%{uid}

[realms]
 EXAMPLE.NET = {
  kdc = dce.example.net
  kdc = dcf.example.net
  admin_server = dce.example.net
  kdc = dce.example.net
  kdc = dcf.example.net
 }

[domain_realm]
 example.net = EXAMPLE.NET
 .example.net = EXAMPLE.NET
```

# kinit -R should work after a renewal with the proper configuration settings.

*refreshing the cache file so we can see our klist* 

```
[root@myserver ~]#  kinit -V my_user@EXAMPLE.NET
Using default cache: persistent:0:0
Using principal: my_user@EXAMPLE.NET
Password for my_user@EXAMPLE.NET:
Authenticated to Kerberos v5
```

```
[root@myserver ~]# klist
Ticket cache: KEYRING:persistent:0:0
Default principal: my_user@EXAMPLE.NET

Valid starting       Expires              Service principal
12/10/2020 09:37:53  12/10/2020 19:37:53  krbtgt/EXAMPLE.NET@EXAMPLE.NET
        renew until 12/17/2020 09:37:49
```




ref:
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/windows_integration_guide/index


