# How to share variables across Puppet environments.

The Problem we are trying to solve. Keep things simple. Reduce repeats of data. 


## step one store some data in your production environment's common.yaml or common.yaml

```
---
#filename: common.eyaml 
clearv1: test123
```


## step load the common file from hiera on the set environment.

Example: in Dev.

```
---
version: 5
#filename: hiera.yaml
#evironment: development
defaults:
  datadir: "data"
hierarchy:
  - name: "Secret data: per-node, per-datacenter, common"
    lookup_key: eyaml_lookup_key # eyaml backend
    paths:
      - "secrets/nodes/%{trusted.certname}.eyaml"  # Include explicit file extension
      - "secrets/location/%{facts.whereami}.eyaml"
      - "/etc/puppetlabs/code-staging/environments/production/data/common.eyaml" ####<----Info from Production is shared accross environemnts
    options:
      pkcs7_private_key: /var/lib/puppet/keys/private_key.pkcs7.pem
      pkcs7_public_key:  /var/lib/puppet/keys/public_key.pkcs7.pem
  - name: "Normal data"
    data_hash: yaml_data # Standard yaml backend
    paths:
      - "nodes/%{trusted.certname}.yaml"
      - "location/%{facts.whereami}/%{facts.group}.yaml"
      - "groups/%{facts.group}.yaml"
      - "os/%{facts.os.family}.yaml"
      - "common.yaml"
```

## Test from your development environment

```
[root@myhost ~]# puppet lookup clearv1 --environment development
--- test123
```