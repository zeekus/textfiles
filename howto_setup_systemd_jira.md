# How to make a systemd startup file for JIRA

1. create new startup file service 

```
sudo vi /usr/lib/systemd/system/jira.service
```

# 2. contents of startup script for systemd
``` 
[Unit]
Description=JIRA Service
After=network.target iptables.service firewalld.service firewalld.service httpd.service

[Service]
Type=forking
User=jira
Environment=JRE_HOME=/usr/java/jdk1.8.0_74
ExecStart=/opt/jira710/bin/start-jira.sh
ExecStop=/opt/jira710/bin/stop-jira.sh
ExecReload=/opt/jira710/bin/stop-jira.sh | sleep 60 | /opt/jira710/bin/start-jira.sh

[Install]

WantedBy=multi-user.target
```

# 3. reload systemd deamon
```
sudo systemctl deamon-reload
```

# 4. tell service to start 
 ```
 sudo systemctl start jira
 ```
 
# 5. enable service to start upon reboots
```
sudo systemctl enable jira
```

# 6. verify service is started and set to run on reboots
```
sudo systemctl status jira
```
# mostly copied: 
source: https://confluence.atlassian.com/jirakb/run-jira-as-a-systemd-service-on-linux-979411854.html
