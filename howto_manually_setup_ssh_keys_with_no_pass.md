# manually setup keys for passwordless login

**in this example, we will be creating the private key on the orginating machine.**

# 1. run key gen to get an rsa key

```
ssh-keygen -t rsa -f my_rsa_key.pem
```

This creates two files:

Private key: my_rsa_key.pem  
Public key:  my_rsa_key.pem.pub

# 2 display and copy key elsewhere

```
cat my_rsa_key.pem
cat my_rsa_key.pem.pub
```

# 3 edit the public key and remove the host info

```
[myuser@myhost test]$ cat my_rsa_key.pem.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjejpDIaYrcFVOcmaAJYmUZbv2m1bXeNFGoL7HPJEkxiIwDSdWTa+YKecEj+FydfMaM+HlqUmSosT7B+CPPfXbM96Np54HLVjOoejaKkxmy9P96a32U5lxtEs/0c79Z1LE75u7h0DQvHsd9tAe7pMfC4gOzvWopudtmzTCYUlyY69khmXNB9d6CJ26/gnaGOjihogwCgsBDycCIa2X+oaJVNcbQtWTfpP2Hem9MHBr3Yr/aEa14cSLI0VdHhQNFJb07VZX+EAK8nrTYafDcYiNxo0rqyyt46po9S9NoQ7M2HMVyUe7cUngJjF4hZKy4q3v2Vmn5K6j6km9OKytv+CT myuser@myhost
```

```
[myuser@myhost test]$ cat my_rsa_key.pem.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjejpDIaYrcFVOcmaAJYmUZbv2m1bXeNFGoL7HPJEkxiIwDSdWTa+YKecEj+FydfMaM+HlqUmSosT7B+CPPfXbM96Np54HLVjOoejaKkxmy9P96a32U5lxtEs/0c79Z1LE75u7h0DQvHsd9tAe7pMfC4gOzvWopudtmzTCYUlyY69khmXNB9d6CJ26/gnaGOjihogwCgsBDycCIa2X+oaJVNcbQtWTfpP2Hem9MHBr3Yr/aEa14cSLI0VdHhQNFJb07VZX+EAK8nrTYafDcYiNxo0rqyyt46po9S9NoQ7M2HMVyUe7cUngJjF4hZKy4q3v2Vmn5K6j6km9OKytv+CT
```

# 4 add contents of public key to authorized_keys

```
cat >> ~/.ssh/authorized_keys < my_rsa_key.pem.pub
```

# 5 test private key on machine you will be connecting from and use

```
ssh -i myprivate_key.pem myuser@myhost
```
