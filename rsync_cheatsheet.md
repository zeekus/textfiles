
# Example of using rsync for one user who is differnent than the initator using a user that has sudo rights. 

```
sudo -E rsync -avxP --delete --rsh="ssh" --rsync-path="sudo rsync" /home/u/myuser/ rocky@server2:/home/u/myuser/
```


#  Example of Rsync from a source with a different user than destination. Sudo called to keep all the permissions the same as the source. 
*Note* the source data is /home/u but we add a "/" so rsync doesn't put /home/u inside /home/u resulting in /home/u/home/u at the destination. 
delete is called to delete files at the destination that don't exist on the source. 

```
sudo -E rsync -avxP --delete --rsh="ssh -i mysshkey.pem" --rsync-path="sudo rsync" /home/u/ rocky@server2:/home/u/
```

refs:

https://phoenixnap.com/kb/how-to-rsync-over-ssh

https://linuxize.com/post/how-to-transfer-files-with-rsync-over-ssh/

https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories

