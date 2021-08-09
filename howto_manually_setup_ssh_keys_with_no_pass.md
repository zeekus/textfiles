# manually setup ssh keys for passwordless login

**in this example, we will be creating the private key on the orginating machine.**
**note the ssh key can be generated anywhere.**
**Manual generation of keys is ocassionally needed when a system that doesn't allow users to login with regular credentals.**

# 1. run key gen to get an rsa key with the filename my_rsa_key.pem

```
ssh-keygen -t rsa -f my_rsa_key.pem
```

This creates two files:

Private key: my_rsa_key.pem  
Public key:  my_rsa_key.pem.pub

# 2 edit the public key and remove the host info

```
[myuser@myhost test]$ cat my_rsa_key.pem.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjejpDIaYrcFVOcmaAJYmUZbv2m1bXeNFGoL7HPJEkxiIwDSdWTa+YKecEj+FydfMaM+HlqUmSosT7B+CPPfXbM96Np54HLVjOoejaKkxmy9P96a32U5lxtEs/0c79Z1LE75u7h0DQvHsd9tAe7pMfC4gOzvWopudtmzTCYUlyY69khmXNB9d6CJ26/gnaGOjihogwCgsBDycCIa2X+oaJVNcbQtWTfpP2Hem9MHBr3Yr/aEa14cSLI0VdHhQNFJb07VZX+EAK8nrTYafDcYiNxo0rqyyt46po9S9NoQ7M2HMVyUe7cUngJjF4hZKy4q3v2Vmn5K6j6km9OKytv+CT myuser@myhost
```

Should look like this.

```
[myuser@myhost test]$ cat my_rsa_key.pem.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjejpDIaYrcFVOcmaAJYmUZbv2m1bXeNFGoL7HPJEkxiIwDSdWTa+YKecEj+FydfMaM+HlqUmSosT7B+CPPfXbM96Np54HLVjOoejaKkxmy9P96a32U5lxtEs/0c79Z1LE75u7h0DQvHsd9tAe7pMfC4gOzvWopudtmzTCYUlyY69khmXNB9d6CJ26/gnaGOjihogwCgsBDycCIa2X+oaJVNcbQtWTfpP2Hem9MHBr3Yr/aEa14cSLI0VdHhQNFJb07VZX+EAK8nrTYafDcYiNxo0rqyyt46po9S9NoQ7M2HMVyUe7cUngJjF4hZKy4q3v2Vmn5K6j6km9OKytv+CT
```


# 3 Append the public key to the authorized_key file on the **destination** host. 

Destination: myuser@myserver
Source: myuser@myhost

Allows access from a remote host. 
```
Authorized keys: ~/.ssh/authorized_keys
```

How to append. 

```
cat >> ~/.ssh/authorized_keys < my_rsa_key.pem.pub
```

# 4 test on machine that has the private key. 

source: myuser@myhost
dest:   myuser@myserver

```
[myuser@myhost]$ ssh -i myprivate_key.pem myuser@myserver
```

**Note if you can logon the remote host all this can be done with 'ssh-copy-id'**
