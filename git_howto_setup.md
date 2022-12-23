### Git Cheatsheet

# git basics 

# list the configuration

```
git config --list
```

# list the global, local, system settings

```
git config --list --global
git config --list --local
git config --list --system
```

# configure user as a global
```
git config --global user.name "zeekus"
```

# verify entry got created by looking at it
```
git config --global user.name
```
ref https://docs.github.com/en/get-started/getting-started-with-git/setting-your-username-in-git

# Formating: configure the unix style whitespaces
```
git config --global core.autocrlf true
```

# setup ssh with git *note there are multiple ways to do this*

1. create an ssh key
```
ssh-keygen -t rsa -b 4096 -C "myemail@somewhere.com" -f ~/.ssh/newkey_test
```
2. list the new test ssh key
```
ls ~/.ssh/*test*
newkey_test  newkey_test.pub
```
3. register the newkey_test.pub key in github. 
ref: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account?tool=webui

4. setup ssh locally to be aware to use the new ssh with github

```
cat ~/.ssh/config 
Host github.com
 HostName github.com
 User git
 IdentityFile ~/.ssh/newkey_test
 IdentitiesOnly yes
```
5. test the ssh key with github

```
ssh -T github.com -i ipmasqman@gmail.com
Warning: Identity file ipmasqman@gmail.com not accessible: No such file or directory.
Hi zeekus! You've successfully authenticated, but GitHub does not provide shell access.
```

# clone a repo to a local repo using ssh *primary method*

```
git clone git@github.com:zeekus/textfiles.git #for ssh git using ssh keys. 
```

# if you can't use SSH clone a local repo using the legacy https method. *alternative method*

```
git clone https://github.com/zeekus/textfiles.git #for https authentication - legacy method. creates authentication issues. 
```

# create a basic commit in your repot

*add or submit modification*

```
cd textfiles
touch mynew_file.txt
git add . #not the . is short cut for all
git commit -m "added debug file" 
git push
```

# list edits and chage history using the commit log
```
 git log --oneline
```

## undo local changes and reset it to the remote 

```
git reset
```

## remove last change - git doesn't have an 'undo' per say - see REF to undoing changes below

get last commit number. This is were the change description becomes important.

``` 
git log --online 
```

revert the commit you want to undo.  In this example, the last commit was '19fb737'.

```
git revert 19fb737
push git
```

# list branches
```
git branch
```


# create a branch called 'test' 

```
git  checkout -b test
```


# how to delete a remote branch

# List the branches you are working.
```
* test
  test1
  list
  master
```

# delete the remote branch you want dropped
```
git push origin --delete test1
```

# create some git aliases

```
git alias.ci=commit -m
git alias.unstage=reset HEAD
git alias.st=status
```

# list your git alias
```
git config --get-regexp ^alias 
```

*or* 

```
git config --list | grep -i alias
```

REF:
source: https://www.educative.io/edpresso/how-to-delete-remote-branches-in-git

Best REF for undoing changes: https://www.atlassian.com/git/tutorials/undoing-changes
