### Git Cheatsheet

# git basics 

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

## list edits and chage history
```
 git log --oneline
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




source: https://www.educative.io/edpresso/how-to-delete-remote-branches-in-git
