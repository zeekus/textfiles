
# examples of getting data from NT client



## List services: 

```
[root@myserver ~]# /usr/lib64/nagios/plugins/check_nt -H domaincontroller.example.net -p 12489 -v INSTANCES -l Process
Idle,System,smss,csrss,wininit,csrss,winlogon,services,lsass,svchost,svchost,LogonUI,svchost,dwm,svchost,svchost,svchost,svchost,svchost,spoolsv,Microsoft.ActiveDirectory.WebServices,start-amazon-cloudwatch-agent,amazon-cloudwatch-agent,conhost,LiteAgent,VxLockdownServer,dfsrs,svchost,dns,ismserv,nscp,NwxExeSvc,ccSvcHst,ccSvcHst,sepWscSvc64,svchost,svchost,Netwrix.WSA.AgentService,WmiPrvSE,WmiPrvSE,dfssvc,Ec2Config,bedbg,beremote,unsecapp,UAVRAgent,vds,svchost,iashost,msdtc,NwxNlaAgent,conhost,VSSVC,svchost,WmiPrvSE,_Total
```

# find client version
```
[root@myserver ~]# /usr/lib64/nagios/plugins/check_nt -H domaincontroller.example.net -p 12489 -v CLIENTVERSION
NSClient++ 0.4.3.143 2015-04-29
```

# get uptime

```
[root@myserver ~]# /usr/lib64/nagios/plugins/check_nt -H domaincontroller.example.net -p 12489 -v UPTIME
System Uptime - 0 day(s) 4 hour(s) 13 minute(s) |uptime=253
```

# get cpu load
```
[root@myserver win_conf.d]# /usr/lib64/nagios/plugins/check_nt -H domaincontroller.example.net -p 12489 -v CPULOAD -l 5,80,90
CPU Load 9% (5 min average) |   '5 min avg Load'=9%;80;90;0;100
```