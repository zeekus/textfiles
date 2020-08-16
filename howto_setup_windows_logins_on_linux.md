# Draft started 8/14/2020

# How to setup Linux to connect to a Windows domain

Linux can use AD as a authentication method. There are multiple tools that can be used to this.

# Linux tools to join a domain

#adcli - mostly widely used
#realmmd -
#authconfig - 

# configuration files that control domain registration seem to gt created by the tools that 


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

