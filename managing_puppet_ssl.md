## Managing Puppet SSL certificates

# List SSL certificates on the system

```
puppetserver ca list --all | grep -v 'pe-int\|console-cert'
```

# Remove last system added to list

```
puppetserver ca clean --certname $(puppetserver ca list --all | grep -v 'pe-int\|console-cert'| tail -n 1| awk '{print $1}' )
```



