
Problem SELinux is blocking the nrpe nagios client from accessing the disk.

Signiture of issue appears in audit logs:
```  
[root@alma-test ~]# cat /var/log/audit/audit.log | grep -i disk | grep -i denied  | head -1
type=AVC msg=audit(1652710206.679:6421): avc:  denied  { getattr } for  pid=541308 comm="check_disk" path="/sys/fs/cgroup" dev="tmpfs" ino=14135 scontext=system_u:system_r:nrpe_t:s0 tcontext=system_u:object_r:cgroup_t:s0 tclass=dir permissive=0
```

This can be fixed with the audit2allow command and followed by a'semodule -i'.

```
cat /var/log/audit/audit.log | grep -i disk | grep -i denied | audit2allow -M disk_check
semodule -i disk_check.pp
```