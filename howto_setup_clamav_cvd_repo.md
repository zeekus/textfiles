## How to setup and run cvd.

# install cvd 

```
pip3 install cvdupdate
```


# clean up old configuation data 

```
 cvd clean all
```

# create a store for the data

```
mkdir -p /var/tmp/clamav
```

# configure cvd us to use the new data store

```
cvd config set --dbdir /var/tmp/clamav
```

source: https://pypi.org/project/cvdupdate/