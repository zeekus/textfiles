
## Troubleshooting domain joins from linux:


# list the keytab info

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

```
[root@myserver_example ~]# net cache list |head
Key: IDMAP/SID2XID/S-1-5-21-780216973-25257766-102967255-13433   Timeout: Tue Aug 18 13:26:58 2020       Value: 16777234:G
Key: IDMAP/GID2SID/16777250      Timeout: Tue Aug 18 13:26:58 2020       Value: S-1-5-21-780216973-25257766-102967255-11524
Key: IDMAP/SID2XID/S-1-5-21-780216973-25257766-102967255-15552   Timeout: Tue Aug 18 13:26:58 2020       Value: 16777270:G
Key: IDMAP/SID2XID/S-1-5-21-780216973-25257766-102967255-16536   Timeout: Tue Aug 18 13:26:58 2020       Value: 16777297:G
Key: IDMAP/GID2SID/16777311      Timeout: Tue Aug 18 13:26:58 2020       Value: S-1-5-21-780216973-25257766-102967255-12050
```

# manually rejoin the domain

```
[root@myserver_example ~]# kinit my_user@EXAMPLE.NET
Password for my_user@EXAMPLE.NET:

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

ref:
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/windows_integration_guide/index


