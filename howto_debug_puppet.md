#Draft started 8/19/2020

#How to debug puppet runs

```
puppet agent -tv --noop --explain
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