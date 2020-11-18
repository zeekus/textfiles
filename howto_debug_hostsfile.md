Problem: Ocassionally a goofy hosts file can cause all types of networking issues that seem to point to different applications.

In this particular debugging session, 'monit' was not able to check the httpd status on my host. 
In troubleshooting, the problem did not appaer obvious. I checked the apache logs and monit didn't provide a log file. 
After checking selinux and apache,  I started looking at the hosts file.

# The original host file looked like this.

It appears it was a /etc/hosts file issue. 'monit' couldn't find 'localhost'. 

```
[root@mywebserver1s ~]# cat /etc/hosts | grep -v ^#
127.0.0.1   mywebserver1s.us-east.aws.example.net mywebserver1s
127.0.0.1   localhost.localdomain localhost
127.0.0.1   localhost4.localdomain4 localhost4

::1 mywebserver1s.us-east.aws.example.net mywebserver1s
::1 localhost.localdomain localhost
::1 localhost6.localdomain6 localhost6

10.128.4.10   dce dce.example.net
10.128.4.140  dcf dcf.example.net
```

# Debugging host file: 

*before cleanup*

```
[root@mywebserver1s ~]# getent hosts 127.0.0.1
127.0.0.1       mywebserver1s.us-east.aws.example.net mywebserver1s
[root@mywebserver1s ~]# getent hosts localhost
::1             localhost.localdomain localhost
```

# Host file After cleanup

* following default centos6 hostfile syntax. 
source: https://forums.centos.org/viewtopic.php?t=42640

```
127.0.0.1 myserver1s.us-east.aws.example.net myserver1s localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
```

*Debugging: after change*

```
[root@mywebserver1s ~]# getent hosts localhost4
127.0.0.1       mywebserver1s.us-east.aws.example.net mywebserver1s localhost.localdomain localhost localhost4.localdomain4 localhost4
[root@mywebserver1s ~]# getent hosts 127.0.0.1
127.0.0.1       mywebserver1s.us-east.aws.example.net mywebserver1s localhost.localdomain localhost localhost4.localdomain4 localhost4
[root@mywebserver1s ~]# getent hosts localhost
127.0.0.1       mywebserver1s.us-east.aws.example.net mywebserver1s localhost.localdomain localhost localhost4.localdomain4 localhost4
```


# monit status before

```
[root@myserver1s etc]# monit status
Monit 5.25.1 uptime: 11m

Process 'httpd'
  status                       Connection failed
  monitoring status            Monitored
  monitoring mode              active
  on reboot                    start
  pid                          4621
  parent pid                   1
  uid                          0
  effective uid                0
  gid                          0
  uptime                       0m
  threads                      1
  children                     8
  cpu                          -
  cpu total                    -
  memory                       0.3% [12.5 MB]
  memory total                 1.8% [70.4 MB]
  security attribute           unconfined_u:system_r:httpd_t:s0
  disk write                   0 B/s [48 kB total]
  port response time           FAILED to [localhost]:80 type TCP/IP protocol HTTP
  data collected               Mon, 16 Nov 2020 15:14:50

System 'myserver1s.us-east.aws.example.net'
  status                       OK
  monitoring status            Monitored
  monitoring mode              active
  on reboot                    start
  load average                 [0.01] [0.00] [0.00]
  cpu                          0.3%us 0.3%sy 0.0%wa
  memory usage                 324.5 MB [8.2%]
  swap usage                   0 B [0.0%]
  uptime                       34m
  boot time                    Mon, 16 Nov 2020 14:40:19
  data collected               Mon, 16 Nov 2020 15:14:50
```