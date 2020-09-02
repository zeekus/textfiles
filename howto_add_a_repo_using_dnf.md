
## How to add a repository using dnf

# 1 clean the cache

```
[root@myclient1 yum.repos.d]# dnf clean all
```

# 2 enable the desired repos

```
[root@myclient1 ]# dnf config-manager --set-enabled epel
[root@myclient1 ]# dnf config-manager --set-enabled epel-playground
[root@myclient1 ]# sudo yum config-manager --set-enabled PowerTools
```

# 3 run the upgrade

```
dnf upgrade
```

# 4 source:
https://docs.fedoraproject.org/en-US/Fedora/23/html/System_Administrators_Guide/sec-Managing_DNF_Repositories.html#:~:text=Adding%20a%20DNF%20Repository,repos.