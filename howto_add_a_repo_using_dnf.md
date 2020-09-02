
## How to add a repository using dnf

# 1 clean the cache

```
[root@sshd0d yum.repos.d]# dnf clean all
```

# 2 enable the desired repos

```
[root@sshd0d yum.repos.d]# dnf config-manager --set-enabled epel
[root@sshd0d yum.repos.d]# dnf config-manager --set-enabled epel-playground
```

# 3 run the upgrade

```
dnf upgrade
```

# 4 source:
https://docs.fedoraproject.org/en-US/Fedora/23/html/System_Administrators_Guide/sec-Managing_DNF_Repositories.html#:~:text=Adding%20a%20DNF%20Repository,repos.