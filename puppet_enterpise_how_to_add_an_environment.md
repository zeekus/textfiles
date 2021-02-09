# How to create new enviornment in puppet enterprise with code-manager enabled.

## 1. add a branch to your repo 
   Production  -> Create branch from here

## 2. set name to awslinux2 
   *note "-" characters are invalid on branches.
   
## 3. run puppet-code deploy on the new environment

```
[root@mypuppetserver ~]# puppet-code  deploy awslinux2
Found 1 environments.
[
  {
    "environment": "awslinux2",
    "id": 28,
    "status": "queued"
  }
]
```

## 4. In 'Puppet Enterprise' web interface 'Add group' to node groups.
 select 'All Environment' 
 select 'Environment' The new 'awslinux2' environment should be selectable. 
 enter a group name 
 click on enviornment group 