# AWS Pcluster3 cheat sheet.

***

# prerequisite update pip

```
python3 -m pip install --upgrade pip
```

# prerequisite update pip in a virtual environment

```
python3 -m pip install --user --upgrade virtual
```


# setup install pcluster client using a python virtual env

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

# install an older version of pcluster [ downgrade ]

```
python3 -m pip install --upgrade "aws-parallelcluster<3.0"     
```

# creating a custom AMI

1. build an image in ec2


2. create a build file for pcluster

```
Region: us-east-1
Image:
  Name: "custom AMI for Pcluster 3"
Build:
  ParentImage: ami-0c5967ba802384505
  InstanceType: c4.8xlarge
```

3. convert AMI from EC2 into cloudwatch

```
(apc-ve) usermy@myuser:/mnt/c/Users/myuser/git/bluefish-scripts$ pcluster build-image --image-id myfirst --image-configuration ./buildcustomami.yaml
{
  "image": {
    "imageId": "myfirst",
    "imageBuildStatus": "BUILD_IN_PROGRESS",
    "cloudformationStackStatus": "CREATE_IN_PROGRESS",
    "cloudformationStackArn": "arn:aws:cloudformation:us-east-1:663667428198:stack/myfirst/85870930-a3aa-11ec-9b07-12c1ac6e884f",
    "region": "us-east-1",
    "version": "3.1.1"
  }
}
(apc-ve) usermy@myuser:/mnt/c/Users/myuser/git/bluefish-scripts$ 
```

upon completetion the pcluster cli will spit out a new ami 

```
(apFc-ve) usermy@myuser:/mnt/c/Users/myuser/git/textfiles$ pcluster describe-image --image-id myfirst --query 'ec2AmiInfo.amiId'
"ami-070973291a18a60e8"
```

list images that are available

```
pcluster list-images -r us-east-1 --image-status AVAILABLE
```

output
```
(apc-ve) usermy@myuser:~/apc-ve/bin$ pcluster list-images -r us-east-1 --image-status AVAILABLE
{
  "images": [
    {
      "imageId": "mysecond",
      "imageBuildStatus": "BUILD_COMPLETE",
      "ec2AmiInfo": {
        "amiId": "ami-0849b3cca0757b921"
      },
      "region": "us-east-1",
      "version": "3.1.2"
    },
    {
      "imageId": "hpc05032022",
      "imageBuildStatus": "BUILD_COMPLETE",
      "ec2AmiInfo": {
        "amiId": "ami-0dd23be82f10e402c"
      },
      "region": "us-east-1",
      "version": "3.1.3"
    }
  ]
}
```

clean up old clusters/images

```(apc-ve) usermy@myuser:/mnt/c/Users/myuser/git/bluefish-scripts$ pcluster delete-cluster -n testami

```
OUTPUT: 
```
{
  "cluster": {
    "clusterName": "testami",
    "cloudformationStackStatus": "DELETE_IN_PROGRESS",
    "cloudformationStackArn": "arn:aws:cloudformation:us-east-1:663667428198:stack/testami/1f9fc2c0-a3b3-11ec-bc5b-0ad021a4c485",
    "region": "us-east-1",
    "version": "3.1.1",
    "clusterStatus": "DELETE_IN_PROGRESS"
  }
}

delete the image

````
(apc-ve) usermy@myuser:/mnt/c/Users/myuser/git/bluefish-scripts$ pcluster delete-image -i myfirst
{
  "image": {
    "imageId": "myfirst",
    "imageBuildStatus": "DELETE_IN_PROGRESS",
    "region": "us-east-1",
    "version": "3.1.1"
  }
}
```

Aliases to activate the pcluster cli
```
#pcluster stuff and move to pcluster dir
alias pcluster_active="source ~/apc-ve/bin/activate"
```

ref: https://aws.amazon.com/blogs/hpc/custom-amis-with-parallelcluster-3/