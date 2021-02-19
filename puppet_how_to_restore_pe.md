# basic puppet enterprise restore info date: 2/19/2021
This document explains how to restore puppet enterprise to a Centos7 instance.


# 1. centos7 puppet install
blank

# 2. enable epel repo and upate 

``` 
yum -y install epel-release
yum --enablerepo=epel -y install nrpe nagios-plugins
yum update
```

# 3. set host info in the /etc/hosts file

```
[root@myserver]# hostname
myserver
```

```
cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 myserver puppet myserver.example.net
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
```

# 4. Configure puppet firewall ports

```
   firewall-cmd --zone=public --permanent --add-service=https
   firewall-cmd --zone=public --permanent --add-service=http
   firewall-cmd --zone=public --permanent --add-service=nrpe
   firewall-cmd --zone=public --permanent --add-service=puppetmaster
   firewall-cmd reload
   firewall-cmd --list-all --zone=public
```

# 5. copy encryption keys if you use them.
setup keys if you use them

```
mkdir -p /var/lib/puppet/keys
[root@myserver keys]# ls -lah /var/lib/puppet/keys/p*
-r--------. 1 pe-puppet pe-puppet 1.7K Nov 18 13:04 /var/lib/puppet/keys/private_key.pkcs7.pem
-r--------. 1 pe-puppet pe-puppet 1.1K Nov 18 13:04 /var/lib/puppet/keys/public_key.pkcs7.pem
```

# 6. Optional create an /opt partion with at least 10GB of storage

*this depends on your environmment* 

# 7. download the latestet version of puppet and install

https://puppet.com/try-puppet/puppet-enterprise/download/
```
curl -JLO 'https://pm.puppet.com/cgi-bin/download.cgi?dist=el&rel=7&arch=x86_64&ver=latest'
tar xvf puppet-enterprise-2019.8.4-el-7-x86_64.tar.gz
cd puppet-enterprise-2019.8.4-el-7-x86_64
./puppet-enterprise-installer
```
Read the installer output on what to do from here.

# 8. run the restore commands after testing your installation. 

```
 /opt/puppetlabs/bin/puppet-backup restore /home/ted/pe_backup-2021-02-19_16.21.40_UTC.tgz
```

