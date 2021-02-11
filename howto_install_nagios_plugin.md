## How to install nagios plugins

# 1. get packages from nagios plugins
```
wget https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz
```
# 2. untar package

```
tar xzvf nagios-plugins-2.3.3.tar.gz
cd nagios-plugins-2.3.3/
```

# 3. install required compilers

```
sudo yum install gcc glibc glibc-common
```

# 4. Complile with Nagios user

```
./configure --with-command-group=nagios
make all
```

source: https://sysadminxpert.com/step-by-step-method-for-installing-nagios-in-amazon-linux/