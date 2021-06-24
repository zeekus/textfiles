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

# manual run

```
cvd update
```

# setup a cronjob for this

```
whereis cvd
cvd: /usr/local/bin/cvd

crontab -e
30 */4 * * * /bin/sh -c "/usr/local/bin/cvd update &> /dev/null"
```

# copy data to s3 if needed

```
aws s3 sync /var/tmp/clamav/ s3://mystore/clamav
```


source: https://pypi.org/project/cvdupdate/