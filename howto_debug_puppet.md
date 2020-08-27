#Draft started 8/19/2020

#How to debug puppet runs

# puppet dry runs with no changes
```
puppet agent -tv --noop -
```

# How to debug Yaml variables.
Yaml varabibles get set in either eymal or yaml files.

Lookups can be used to query thme from the 'puppet server'. Here are some examples.

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
