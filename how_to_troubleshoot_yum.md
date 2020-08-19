Troubleshooting Yum

#draft 8/19/2020


# get a list of the repos we are subscribed to.

```
yum repolist all
```


# disable a repos
```
  yum-config-manager --disable centos-sclo-rh
```

enable a new version of php
```
 yum-config-manager --enable remi-php74
```

check for locked versions

```
yum versionlock list
```

