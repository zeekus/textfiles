
Problem: Ocassionally Jira plugsins will not install.

Here is a signiture of what it looks like on the file system. Note there multiple copies of the plugin in the temp directory.
The work around is to manually move the jar file where it needs to go.

A signiture of the problem looks like this: 

```
/var/atlassian/atlassian-jira/atlassian-jira-software-8.13.6-standalone/temp/plugin.6680008716002709535.atlassian-universal-plugin-manager-plugin-4.3.4.jar
/var/atlassian/atlassian-jira/atlassian-jira-software-8.13.6-standalone/temp/plugin.3497824875249912763.atlassian-universal-plugin-manager-plugin-4.3.4.jar
/var/atlassian/atlassian-jira/atlassian-jira-software-8.13.6-standalone/temp/plugin.5257398288218577309.atlassian-universal-plugin-manager-plugin-4.3.4.jar
/var/atlassian/atlassian-jira/atlassian-jira-software-8.13.6-standalone/temp/plugin.4750705142244579348.atlassian-universal-plugin-manager-plugin-4.3.4.jar
/var/atlassian/atlassian-jira/atlassian-jira-software-8.13.6-standalone/temp/plugin.5658777994671149487.atlassian-universal-plugin-manager-plugin-4.3.4.jar
/var/atlassian/atlassian-jira/atlassian-jira-software-8.13.6-standalone/temp/plugin.4313133761335596708.atlassian-universal-plugin-manager-plugin-4.3.4.jar
/var/atlassian/atlassian-jira/atlassian-jira-software-8.13.6-standalone/temp/plugin.8570940197231701308.atlassian-universal-plugin-manager-plugin-4.3.4.jar
/var/atlassian/atlassian-jira/atlassian-jira-software-8.13.6-standalone/temp/plugin.1163637102141548604.atlassian-universal-plugin-manager-plugin-4.3.4.jar
/var/atlassian/atlassian-jira/atlassian-jira-software-8.13.6-standalone/temp/plugin.2108387322099663765.atlassian-universal-plugin-manager-plugin-4.3.4.jar
/var/atlassian/atlassian-jira/atlassian-jira-software-8.13.6-standalone/temp/plugin.8280631747389745964.atlassian-universal-plugin-manager-plugin-4.3.4.jar
/var/atlassian/atlassian-jira/atlassian-jira-software-8.13.6-standalone/temp/plugin.7856690912607600669.atlassian-universal-plugin-manager-plugin-4.3.4.jar
```



Fix a plugin manual move the jar file:

# 1 stop jira 

```
systemctl stop jira
```

# 2 remove old plugin 

```
rm /var/atlassian/application-data/jira-home/plugins/installed-plugins/*universal-plugin-manager-plugin*
```

# 3 move over the new plugin 

```
mv ./atlassian-jira/atlassian-jira-software-8.13.6-standalone/temp/plugin.7896532935671158581.atlassian-universal-plugin-manager-plugin-4.3.4.jar ./application-data/jira-home/plugins/installed-plugins/.
```
# 4 start jira and test

```
systemctl start jira
```

