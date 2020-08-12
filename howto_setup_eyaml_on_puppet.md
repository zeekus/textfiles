# How to setup eyaml on puppet enterprise in a unique environment.
Tested on PE v2019.8.0 with code manager enabled.
Version of hiera-eyaml: 3.2.0

# 1. hiera-eyaml comes installed with puppet

```
  [myuser@testpuppetserver1 keys]$ eyaml version
  [hiera-eyaml-core] hiera-eyaml (core): 3.2.0
```

# 2. Create some private keys are needed for things to work.
create keys
```
[myuser@testpuppetserver1 ~]$ eyaml createkeys
[hiera-eyaml-core] Keys created OK
[hiera-eyaml-core] Created key directory: ./keys
```
# 3. copy the new private and public keys to either '/var/lib/puppet/keys' or '/etc/puppetlabs/puppet/eyaml' and make the keys ro
    source: https://github.com/voxpupuli/hiera-eyaml

```
   mkdir -p /var/lib/puppet/keys
   sudo cp ~/keys/*.pem /var/lib/puppet/keys/.
   sudo chmod 400 /var/lib/puppet/keys/*.pem
   chown -R pe-puppet:pe-puppet /var/lib/puppet
```

# 4. verfiy the permissions look right

```
[root@testpuppetserver1 lib]# find /var/lib/puppet -type f
/var/lib/puppet/keys/private_key.pkcs7.pem
/var/lib/puppet/keys/public_key.pkcs7.pem
[root@testpuppetserver1 lib]# find /var/lib/puppet -type f -exec ls -lah {} ';'
-r--------. 1 pe-puppet pe-puppet 1.7K Aug 12 13:41 /var/lib/puppet/keys/private_key.pkcs7.pem
-r--------. 1 pe-puppet pe-puppet 1.1K Aug 12 13:41 /var/lib/puppet/keys/public_key.pkcs7.pem
```

# 5. modify the hierachy in the environment you wish to setup

```
---
version: 5
#environment: production
#repo: Control-repo
#filename: hiera.yaml
#source:  source: https://github.com/voxpupuli/hiera-eyaml

defaults:
  datadir: "data"

hierarchy:
  - name: "Secret data: per-node, per-datacenter, common"
    lookup_key: eyaml_lookup_key # eyaml backend
    paths:
      - "secrets/nodes/%{trusted.certname}.eyaml"  # Include explicit file extension
      - "secrets/location/%{facts.whereami}.eyaml"
      - "common.eyaml"
    options:
      pkcs7_private_key: /var/lib/puppet/keys/private_key.pkcs7.pem
      pkcs7_public_key:  /var/lib/puppet/keys/public_key.pkcs7.pem
  - name: "Normal data"
    data_hash: yaml_data # Standard yaml backend
    paths:
      - "nodes/%{trusted.certname}.yaml"
      - "location/%{facts.whereami}/%{facts.group}.yaml"
      - "groups/%{facts.group}.yaml"
      - "os/%{facts.os.family}.yaml"
      - "common.yaml"
```

# 6. Tell eyaml where to find the keys



```
mkdir -p /etc/eyaml
cat > /etc/eyaml/config.yaml
---
pkcs7_private_key: '/var/lib/puppet/keys/private_key.pkcs7.pem'
pkcs7_public_key:  '/var/lib/puppet/keys/public_key.pkcs7.pem'
[control d]
```

The finished product should look like this:
```
[root@testpuppetserver1 ~]# cat /etc/eyaml/config.yaml
---
pkcs7_private_key: '/var/lib/puppet/keys/private_key.pkcs7.pem'
pkcs7_public_key:  '/var/lib/puppet/keys/public_key.pkcs7.pem'
```

# 7. In your repo create a common.eyaml file and put in your secrets.

This is how you would create a simple encrypted variable. 

```
[root@testpuppetserver1 ~]# eyaml encrypt -p -l mysecretpassword
Enter password: *****************

[root@testpuppetserver1 ~]# eyaml encrypt -p -l mysecretvariable
Enter password: ***********
mysecretvariable: ENC[PKCS7,MIIBeQYJKoZIhvcNAQcDoIIBajCCAWYCAQAxggEhMIIBHQIBADAFMAACAQEwDQYJKoZIhvcNAQEBBQAEggEAsWfSQXa7CFxZq7cfZJJaE0NMnuAx8BCGwqByWth3oFRwbZDxUU5stJyavmpcMP8udf1x12dGfgK7GNiWTSm1fxApjMTHKISW63bCTv5ScaXnVF9KmQvAQj46YYi4QNFJq2C3qldNVuushPoKUx4SqMDUA85KzYzFCVX/wJKUsx5ioWUd2R+GPsN0PgZ9NtnPi3X18dst1gDYl88jPht5705kKrOFYoF3CJEAsS7XHE/NuCXABdYoAxooQeH3p2UM7fzboWZkvihO6Jbd7i7HuF7kC+Ee0u2JSNtNOu0DzCmUPL4KO2qtf/7pWRdpPEYSbll0OaO1gBlCFs/TV5QEEzA8BgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBBPqjRxw6F9a8/wMfGlqYb1gBCJQ6Idp8RSKQzGP878NIAf]

OR

mysecretvariable: >
    ENC[PKCS7,MIIBeQYJKoZIhvcNAQcDoIIBajCCAWYCAQAxggEhMIIBHQIBADAFMAACAQEw
    DQYJKoZIhvcNAQEBBQAEggEAsWfSQXa7CFxZq7cfZJJaE0NMnuAx8BCGwqBy
    Wth3oFRwbZDxUU5stJyavmpcMP8udf1x12dGfgK7GNiWTSm1fxApjMTHKISW
    63bCTv5ScaXnVF9KmQvAQj46YYi4QNFJq2C3qldNVuushPoKUx4SqMDUA85K
    zYzFCVX/wJKUsx5ioWUd2R+GPsN0PgZ9NtnPi3X18dst1gDYl88jPht5705k
    KrOFYoF3CJEAsS7XHE/NuCXABdYoAxooQeH3p2UM7fzboWZkvihO6Jbd7i7H
    uF7kC+Ee0u2JSNtNOu0DzCmUPL4KO2qtf/7pWRdpPEYSbll0OaO1gBlCFs/T
    V5QEEzA8BgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBBPqjRxw6F9a8/wMfGl
    qYb1gBCJQ6Idp8RSKQzGP878NIAf]

```

only one of the two needs to be added. Use 'double quotes around the string to prevent errors'.


# 8. after code deploy is run test with lookup

```
sudo puppet lookup --environment production mysecretvariable 
```




