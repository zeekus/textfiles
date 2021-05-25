# Problem - Mailman permssions acting up

- Signiture of issue: cron not able to run

```
```
List: aws-billing: problem processing /var/lib/mailman/lists/aws-billing/digest.mbox:
[Errno 13] Permission denied: '/var/lib/mailman/archives/private/aws-billing/attachments/20151110/e2f23638/attachments.lock.myserver0.20271.2'

List: mylist2: problem processing /var/lib/mailman/lists/mylist2/digest.mbox:
[Errno 13] Permission denied: '/var/lib/mailman/archives/private/mylist2/attachments/20210126/1f7ff3b1/attachments.lock.myserver0.20271.6'
```

**manual run of cronjob**

```
-bash-4.2$ /usr/lib/mailman/cron/nightly_gzip
Traceback (most recent call last):
  File "/usr/lib/mailman/cron/nightly_gzip", line 154, in <module>
    main()
  File "/usr/lib/mailman/cron/nightly_gzip", line 140, in main
    compress(f)
  File "/usr/lib/mailman/cron/nightly_gzip", line 81, in compress
    outfp = gzip.open(txtfile+'.gz', 'wb', 6)
  File "/usr/lib64/python2.7/gzip.py", line 34, in open
    return GzipFile(filename, mode, compresslevel)
  File "/usr/lib64/python2.7/gzip.py", line 94, in __init__
    fileobj = self.myfileobj = __builtin__.open(filename, mode or 'rb')
IOError: [Errno 13] Permission denied: '/var/lib/mailman/archives/private/mylist1/2020-October.txt.gz'
```

# Solution - manually change the permissions

```
su - mailman -s /bin/bash/ -R
```

```
cd /var/lib/mailman/archives
[root@myserver0 archives]# ls -lah
total 4.0K
drwxrwsr-x.  4 root   mailman   35 Feb  2 07:21 .
drwxrwsr-x.  6 root   root      79 Feb  2 07:23 ..
drwxrws---. 21 apache mailman 4.0K Feb  2 07:23 private
drwxrwsr-x.  3 root   mailman   23 Feb  2 07:23 public

```

Fix: 

```
chown mailman /var/lib/mailman/archives/private/ -R
chown mailman /var/lib/mailman/archives/public/ -R
```

Test:

```
su - mailman -s /bin/bash/ -R

-bash-4.2$ /usr/lib/mailman/bin/check_perms
No problems found
```

** run cron manually **

```
-bash-4.2$ /usr/lib/mailman/cron/nightly_gzip
```

exit 0
