# How to setup a HPC cluster using AWS Parrallel


## 1. verify you have admin aws credentials or create them.

```
(newcluster) [myuser@myserver1 .parallelcluster]$ aws configure
AWS Access Key ID [****************T42J]:
AWS Secret Access Key [****************c3hX]:
Default region name [us-east-1]:
Default output format [None]:
```

## 2. install the pcluster cli

The pcluster cli is a python application that allows you build a HPC cluster from a configuration file.

```
sudo python3 -m pip install --upgrade pip
python3 -m pip install --user --upgrade virtualenv

#activate the cli
source ~/newcluster/bin/activate

#run an update
python3 -m pip install --upgrade aws-parallelcluster
```

## 3. create a basic ini file.

We are using micro instances for testing.

```
[global]
sanity_check = true
update_check = true
cluster_template = default

[aws]
aws_region_name = us-east-1

[cluster default]
#os choices alinux,centos6,centos7,ubuntu1404,ubuntu1605,alinux2
base_os = alinux2
# Replace with the name of the key you intend to use.
key_name = mykey
vpc_settings = my-vpc
scheduler = slurm
compute_instance_type = t3.micro
master_instance_type = t3.micro
initial_queue_size=2
max_queue_size=10
#auto scaling
maintain_initial_size = false
min_vcpus = 0
desired_vcpus = 2
```

## 4 convert your file to a standard file. ( Not necessary. )

```
 pcluster-config convert -c simple_cluster.ini -o parsed_simple_cluster.ini
Section [cluster default] from file simple_cluster.ini has been converted and saved into parsed_simple_cluster.ini.
```
## 5 start the culter build using the pcluster cl

*note the builds take about 10 minutes*

```
(newcluster) [myuser@myserver1 .parallelcluster]$ pcluster create mydefault1cluster -c parsed_simple_cluster.ini
Beginning cluster creation for cluster: mydefault1cluster
Creating stack named: parallelcluster-mydefault1cluster
Status: AssociateEIP - CREATE_COMPLETE
Status: parallelcluster-mydefault1cluster - CREATE_COMPLETE
MasterPublicIP: 192.1.1.1
ClusterUser: ec2-user
MasterPrivateIP: 10.128.64.49
```

## 6 list the builds and clean up any orphans if they exist.

```
(newcluster) [myuser@myserver1 .parallelcluster]$ pcluster list --color
mydefault1cluster  CREATE_COMPLETE    2.10.3
mydefault          ROLLBACK_COMPLETE  2.10.3
```

## delete of an orphan

```
(newcluster) [myuser@myserver1 .parallelcluster]$ pcluster delete mydefault
Deleting: mydefault
Status: DELETE_IN_PROGRESS
Cluster deleted successfully.

Checking if there are running compute nodes that require termination...
Compute fleet cleaned up.
```

## 7 verify cleanup

```
(newcluster) [myuser@myserver1 .parallelcluster]$ pcluster list --color
mydefault1cluster  CREATE_COMPLETE  2.10.3
```

## 8 log into the newly created master node

```
(newcluster) [myuser@myserver1 ~]$ pcluster ssh mydefault1cluster -i ~/.ssh/mykey.pem
The authenticity of host '192.1.1.1 (192.1.1.1)' can't be established.
ECDSA key fingerprint is SHA256:mLdOmmA4RZ/h51wexHUBaLzSzgyGUC5Hw44Pw/H0PWk.
ECDSA key fingerprint is MD5:63:ff:d9:81:28:b7:b5:1e:06:15:16:71:d2:fb:b9:3f.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.1.1.1' (ECDSA) to the list of known hosts.
Last login: Tue Mar 30 12:09:27 2021

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
11 package(s) needed for security, out of 23 available
Run "sudo yum update" to apply all updates.
```

source: https://www.hpcworkshops.com/03-hpc-aws-parallelcluster-workshop/07-logon-pc.html

## 9. on the master node verify the cluster was built to specificaitons

```
[ec2-user@ip-10-128-64-49 ~]$ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
compute*     up   infinite      8  idle~ compute-dy-t3micro-[3-10]
compute*     up   infinite      2   idle compute-dy-t3micro-[1-2]

[root@ip-10-128-64-49 ~]# squeue
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
```

## 9. verify the modules are installed and active

```
[root@ip-10-128-64-49 ~]# module av

----------------------------------------------------------------------------------------------------------------------- /usr/share/Modules/modulefiles ------------------------------------------------------------------------------------------------------------------------
dot                         libfabric-aws/1.11.1amzn1.0 module-git                  module-info                 modules                     null                        openmpi/4.1.0               use.own

--------------------------------------------------------------------------------------------------------------- /opt/intel/impi/2019.8.254/intel64/modulefiles/ ---------------------------------------------------------------------------------------------------------------
intelmpi


[root@ip-10-128-64-49 ~]# module load intelmpi
[root@ip-10-128-64-49 ~]# which mpirun
/opt/intel/compilers_and_libraries_2020.2.254/linux/mpi/intel64/bin/mpirun
```

## 10. verfiy the mount points.

```
[root@ip-10-128-64-49 ~]# showmount -e localhost
Export list for localhost:
/opt/slurm 10.128.64.0/20
/opt/intel 10.128.64.0/20
/home      10.128.64.0/20
/shared    10.128.64.0/20
```

## 11. run some basic tests to vefifyt the cluster is working.



```
[root@ip-10-128-64-49 ~]# mpirun -n 4 ./mpi_hello_world
Hello World from Step 1 on Node 2, (ip-10-128-64-49)
Hello World from Step 1 on Node 3, (ip-10-128-64-49)
Hello World from Step 1 on Node 0, (ip-10-128-64-49)
Hello World from Step 1 on Node 1, (ip-10-128-64-49)
Hello World from Step 2 on Node 0, (ip-10-128-64-49)
Hello World from Step 2 on Node 2, (ip-10-128-64-49)
Hello World from Step 2 on Node 1, (ip-10-128-64-49)
Hello World from Step 2 on Node 3, (ip-10-128-64-49)
Hello World from Step 3 on Node 0, (ip-10-128-64-49)
Hello World from Step 3 on Node 2, (ip-10-128-64-49)
Hello World from Step 3 on Node 1, (ip-10-128-64-49)
Hello World from Step 3 on Node 3, (ip-10-128-64-49)
Hello World from Step 4 on Node 0, (ip-10-128-64-49)
Hello World from Step 4 on Node 2, (ip-10-128-64-49)
Hello World from Step 4 on Node 1, (ip-10-128-64-49)
Hello World from Step 4 on Node 3, (ip-10-128-64-49)

[root@ip-10-128-64-49 ~]# cat > submission_script.sbatch << EOF
> #!/bin/bash
> #SBATCH --job-name=hello-world-job
> #SBATCH --ntasks=4
> #SBATCH --output=%x_%j.out
>
> mpirun ./mpi_hello_world
> EOF
[root@ip-10-128-64-49 ~]# sbatch submission_script.sbatch
Submitted batch job 3
[root@ip-10-128-64-49 ~]# squeue
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
                 3   compute hello-wo     root CF       0:03      2 compute-dy-t3micro-[1-2]
[root@ip-10-128-64-49 ~]# sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
compute*     up   infinite      2 alloc# compute-dy-t3micro-[1-2]
compute*     up   infinite      8  idle~ compute-dy-t3micro-[3-10]
```

source: https://www.hpcworkshops.com/03-hpc-aws-parallelcluster-workshop/08-run-1stjob.html


## 12 clean up test cluster

