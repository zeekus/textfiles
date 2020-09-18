# How to install puppet bolt

source: https://puppet.com/docs/bolt/latest/bolt_installing.html#installing-bolt-on-nix

Install bolt on Centos7:

```
sudo rpm -Uvh https://yum.puppet.com/puppet-tools-release-el-7.noarch.rpm
sudo yum install puppet-bolt
```

After you should get this:

```
[root@lpe1p ~]# bolt --version
2.28.0
```