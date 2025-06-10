Problem: need to reissue ssh keys for code deploy

Summary: reissue and ssh keys for puppet and configure the bitbucket repos to trust the public keys for them. 

# issue new ssh key in /etc/puppetlabs/puppetserver/ssh
```
	   ssh-keygen -t rsa -b 2048 -P '' -f /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa
```  
# run puppet infra config
```
	   puppet infrastructure configure
```
# copy pub key to repo https://bitbucket.org/cbpo-internal/workspace/projects/PUP/settings/access-keys
	 
# Test the ssh key: 
	 
```
           sudo su - pe-puppet -s /bin/bash # forces bash shell on a login with no shell attached. 
	   cd /etc/puppetlabs/puppetserver/ssh
	   ssh -T -i ./id-control_repo.rsa git@bitbucket.org
```
# run a code deploy.
 ```
       time puppet code deploy --all --wait
 ```

# renew the token for 2 hours  
 
 ```
 puppet-access login --lifetime 2h
 ```
# display current puppet token if one exists.

```
puppet-access login admin --print
```
