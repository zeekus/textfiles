# AWS Pcluster3 cheat sheet.

***
# setup install pcluster using a python virtual env

```
$ python3 -m pip install --upgrade pip
$ python3 -m pip install --user --upgrade virtualenv
$ python3  -m virtualenv -p $(which python3) ~/apc-ve
```
source https://docs.aws.amazon.com/parallelcluster/latest/ug/install-v3-virtual-environment.html

***
# activate new virtual environment

```
source ~/apc-ve/bin/activate
```

***
#  convert ini to yaml if you are moving from pcluster2 

```
pcluster3-config-converter -c mypcluster2.ini -c mypcluster3.yaml 

```
https://docs.aws.amazon.com/parallelcluster/latest/ug/pcluster3-config-converter.html
***

# generate a bare bones configuration using the cli

```
$ aws configure
$ pcluster configure --config cluster-config.yaml
```
source https://docs.aws.amazon.com/parallelcluster/latest/ug/install-v3-configuring.html
***

#  build your first cluster

```
pcluster create-cluster --cluster-configuration ./mypcluster3.yaml --cluster-name firstcluster --region us-east-1  
```

***
#  describe your cluster

```
pcluster describe-cluster --cluster-name firstcluster --region us-east-1         
```

# delete cluster 

```
pcluster delete-cluster --cluster-name firstcluster --region us-east-1 
```

# source tree to aws-parallelcluster documentation

https://github.com/awsdocs/aws-parallelcluster-user-guide/tree/main/doc_source
***





