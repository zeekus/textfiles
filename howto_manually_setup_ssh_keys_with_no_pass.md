# manually setup keys for passwordless login

**in this example, we will be creating the private key on the orginating machine.**

# 1. run key gen to get an rsa key

```
ssh-keygen 
```

This creates two files:

Private key: id_rsa
Public key:  id_rsa.pub

#2 display and copy key elsewhere

```
cat id_rsa
cat id_rsa.pub
```

# 3 add contents of public key to authorized_keys

```
cat >> ~/.ssh/authorized_keys < id_rsa.pub
```

# 4 put private key on machine you will be connecting from and use

```
ssh -i myprivate_key.pem myuser@myhost
```
