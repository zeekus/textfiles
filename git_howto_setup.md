### Git Cheatsheet

# git basics 

pre) git configuration info

#configure user
```
git config --global user.name "zeekus"
```

#confirm with
```
git config --global user.name
```
ref https://docs.github.com/en/get-started/getting-started-with-git/setting-your-username-in-git

#configure the unix style whitespaces
```
git config --global core.autocrlf true
```


a) clone a repo

```
git clone https://github.com/zeekus/textfiles.git
```

b) add or submit modification

```
cd textfiles
touch mynew_file.txt
git add --all
git commit -m "added debug file" 
git push
```

# an alias for your bashrc to remind you of the commands

```
alias gitty="echo 'git add --all';echo 'git commit -m \"edit message\"';echo 'git push'"
```
shell:~$ gitty
```
git add --all
git commit -m "edit message"
git push
```


## list edits and chage history
```
 git log --oneline
```

## undo local changes

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
revert 19fb737
push git
```


## how to delete a remote branch

#List the branches you are working.
```
git branch -a
# *master
# test
# test2
# remote/orgin/master
# remote/origin/test
# remote/orgin/test2
```
#delete the remote branch you want dropped
```
git push origin --delete test2
```



REF:
source: https://www.educative.io/edpresso/how-to-delete-remote-branches-in-git

Best REF for undoing changes: https://www.atlassian.com/git/tutorials/undoing-changes
