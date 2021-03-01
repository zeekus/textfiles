Mailman fix notes.

# su to mailman user

```
su -s /bin/bash list
```

# get a list of lists

```
cd ./bin
./list_lists
```

# list lists by a virtual host

```
./list_lists -v annapolislinux.org
./list_lists -v list.annapolislinux.org
```

# rebuild the lists so they use list.annapolislinux.org

```
./withlist -l -r fix_url -u list.annapolislinux.org
```

# rebild aliases using postfix

```
vim /etc/postfix/aliases
newaliases
postfix reload
```
