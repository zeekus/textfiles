#Draft started 8/19/2020

#How to debug puppet runs

# puppet dry runs with no changes
```
puppet agent -tv --noop 
```

# How to debug Yaml variables.
Yaml varabibles get set in either eymal ( if enabled ) or yaml files.

Lookups can be used to query from the 'puppet server'. Here are some examples.

## 1. Querying Common data 

```
---
#source: common.yaml
sudo::configs:
  'centos':
     'priority' : 10
     'content'  : 'centos ALL=(ALL) NOPASSWD: ALL'
```

```
[root@mypuppetserver ~]# puppet lookup --environment centos8_env sudo::configs
---
centos:
  priority: 40
  content: 'centos ALL=(ALL) NOPASSWD: ALL'
```

## 2. Querying node data. 

NOTE fqdn are needed for queries to work.

use the following on puppet to determine the fqdn

```
puppetserver ca list --all | grep -v 'pe-int\|console-cert'
```


```
---
#source: data/nodes/jira1d.example.net.yaml 
jira::version:       '8.8.1'
jira::product_name:  'jira-software'
jira::installdir:    '/opt/atlassian/jira'
jira::homedir:       '/var/atlassian/application-data/jira'
```



```
[root@mypuppetserver ~]# puppet lookup jira::javahome --node jira1d.example.net
--- "/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.201.b09-2.el7_6.x86_64/jre/bin/java"
```

#add a notify statement to your code

If we have a class called, 'config' where we define a variable binary_filename, we can call it elsewhere using the fully qualified path. 

```
 notify { "debug: install class ${cloudwatch::config::binary_filename}":}
```


Example from a class

```
class cloudwatch::install {
  #get RPM from amazon and place in /var/tmp 
  # include ::archive
  include ::cloudwatch::config
  include ::cloudwatch::service



  notify { "debug: install class ${cloudwatch::config::binary_filename}":}

  #install rpm 
  package { "install ${cloudwatch::config::binary_filename}":
    provider => 'rpm',
    ensure   => present,
    source   => "${cloudwatch::config::filepath}",
  }



}
```