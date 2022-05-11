# update puppet cheat cheat.

1. backup puppet

```
/opt/puppetlabs/bin/puppet-backup  create --dir=/var/tmp
```

2. Download the GPG keys to verify the binary

```
uri='https://downloads.puppet.com/puppet-gpg-signing-key-20250406.pub'

curl "$uri" | gpg --import
```



3. # download the latest pe installer and the corresponding asc signiture.  
   https://puppet.com/docs/pe/2021.2/installing_pe.html#install_pe

   https://puppet.com/try-puppet/puppet-enterprise/download/

   If using centos7, use this:
   ```
    wget --content-disposition 'https://pm.puppet.com/cgi-bin/download.cgi?dist=el&rel=7&arch=x86_64&ver=latest'
    wget --content-disposition  https://pm.puppet.com/cgi-bin/download.cgi?dist=el&rel=7&arch=x86_64&ver=latest&type=sig
   ```

4. verify the binary

```
[root@mymachine ~]# gpg --verify puppet-enterprise-2021.5.0-el-7-x86_64.tar.gz.asc
gpg: Signature made Fri 11 Feb 2022 05:07:44 PM EST using RSA key ID 9E61EF26
gpg: Good signature from "Puppet, Inc. Release Key (Puppet, Inc. Release Key) <release@puppet.com>"
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: D681 1ED3 ADEE B844 1AF5  AA8F 4528 B6CD 9E61 EF26
```


5.  uncompress new binary and run installers
   ```
   tar xzvf puppet.tar.gz
   ```

# run installer. 

   