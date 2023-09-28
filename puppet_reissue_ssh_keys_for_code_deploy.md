Problem: need to reissue ssh keys for code deploy

Summary: reissue and ssh keys for puppet and configure the bitbucket repos to trust the public keys for them. 

     # 1. issue new ssh key in /etc/puppetlabs/puppetserver/ssh
     ```
	   ssh-keygen -t rsa -b 2048 -P '' -f /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa
	 ```  
	 # 2. run puppet infra config
     ```
	   puppet infrastructure configure
	 ```
	 # 3. copy pub key to repo https://bitbucket.org/cbpo-internal/workspace/projects/PUP/settings/access-keys
	 
	 # 4. test it: ssh -i ./id-control_repo.rsa -t git@bitbucket.org
	 
	 # 5. run a code deploy.