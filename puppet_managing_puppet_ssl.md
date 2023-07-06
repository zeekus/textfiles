## Managing Puppet SSL certificates

# List SSL certificates on the system

```
puppetserver ca list --all | grep -v 'pe-int\|console-cert'
```

# Remove SSL certificate on from the last system added

```
puppetserver ca clean --certname $(puppetserver ca list --all | grep -v 'pe-int\|console-cert'| tail -n 1| awk '{print $1}' )
```

# deactive the node

```
puppet node deactivate 'myhost.myserver.net'
```

# force purge 

```
puppet node purge 'myhost.myserver.net'
```

# Purge  the last host added completely (depreciated)

```
puppetserver node purge --certname $(puppetserver ca list --all | grep -v 'pe-int\|console-cert'| tail -n 1| awk '{print $1}' )
```


