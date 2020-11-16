Problem: Ocassionally a goofy hosts file can cause all types of networking issues that seem to point to different applications.

In this particular debugging session, monit was not starting on my host. 
In troubleshooting, the problem was not recording the errors that illuminated the issue in the logs.
So, I started looking at the hosts file.

# The original host file looked like this.

On the server apache and expression engine were installed with monit.
However, only monit was not working. So, I originally thought this was 
monit issue. It appears it was a /etc/hosts file issue. 

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
