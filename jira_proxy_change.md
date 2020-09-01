# How to change the proxy from AJP/1.3 to mod_proxy 

# Problem

Jira uses a proxy. With Jira 8.11.0 the legacy AJP/1.3 proxy stops working.
Also, There is the ghost cat vulnerrablity. 
source: http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-1938

# Fix: switch from AJP/1.3 to  mod_proxy

## Part 1: Reconfigure Apache 2.4 to use mod_proxy - ref file:  jira_ssl.conf

```
  ## Proxy rules AJP
  #ProxyRequests Off
  #ProxyPreserveHost Off
  #ProxyPass / ajp://localhost:8009/
  #ProxyPassReverse / ajp://localhost:8009/

 #new proxy rule
 # JIRA Proxy Configuration:
<Proxy *>
        Order deny,allow
        Allow from all
</Proxy>

SSLProxyEngine          On
ProxyRequests           Off
ProxyPreserveHost       On
ProxyPass               / http://localhost:8080
ProxyPassReverse        / http://localhost:8080
```

## Part 2: Reconfigure the application ( in this example Jira) to use new proxy ports - server.xml diffs
```
                    acceptCount="100"
                    disableUploadTimeout="true"
                    redirectPort="8443"
+                   proxyName = 'jira-dev.example.net'
+                   proxyPort = '443'
+                   scheme = 'https'
         />


-        <Connector enableLookups="false" URIEncoding="UTF-8"
-                   port = "8009"
-                   protocol = "AJP/1.3"
-                   redirectPort = "8443"
-        />

         <Engine name="Catalina" defaultHost="localhost">
             <Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">


```

## Part 3: troubleshoot


tail the application error logs and look for issues while trying to connect. 

the httpd application may die when proxy is enabled. SElinux may block a newly created proxy. 

```


[root@ljira1d conf.d]# tail -f /var/log/httpd/jira_ssl_error_ssl.log
[Tue Sep 01 15:14:41.937417 2020] [proxy:error] [pid 20004:tid 139637126948608] (13)Permission denied: AH00957: HTTP: attempt to connect to 127.0.0.1:8080 (localhost) failed
[Tue Sep 01 15:14:41.937461 2020] [proxy_http:error] [pid 20004:tid 139637126948608] [client 10.128.144.8:61037] AH01114: HTTP: failed to make connection to backend: localhost
[Tue Sep 01 15:17:20.802889 2020] [proxy:error] [pid 23920:tid 140239328446208] (13)Permission denied: AH00957: HTTP: attempt to connect to 127.0.0.1:8080 (localhost) failed
[Tue Sep 01 15:17:20.802933 2020] [proxy_http:error] [pid 23920:tid 140239328446208] [client 10.128.144.8:61302] AH01114: HTTP: failed to make connection to backend: localhost
[Tue Sep 01 15:18:14.143304 2020] [proxy:error] [pid 24191:tid 140696856356608] (13)Permission denied: AH00957: HTTP: attempt to connect to 127.0.0.1:8080 (localhost) failed
[Tue Sep 01 15:18:14.143346 2020] [proxy_http:error] [pid 24191:tid 140696856356608] [client 10.128.144.8:61505] AH01114: HTTP: failed to make connection to backend: localhost
[Tue Sep 01 15:19:22.471790 2020] [proxy:error] [pid 24539:tid 139840738027264] (13)Permission denied: AH00957: HTTP: attempt to connect to 127.0.0.1:8080 (localhost) failed
[Tue Sep 01 15:19:22.471869 2020] [proxy_http:error] [pid 24539:tid 139840738027264] [client 10.128.144.8:61598] AH01114: HTTP: failed to make connection to backend: localhost
[Tue Sep 01 15:19:33.302867 2020] [proxy:error] [pid 24539:tid 139840738027264] (13)Permission denied: AH00957: HTTP: attempt to connect to 127.0.0.1:8080 (localhost) failed
[Tue Sep 01 15:19:33.302898 2020] [proxy_http:error] [pid 24539:tid 139840738027264] [client 10.128.144.8:61614] AH01114: HTTP: failed to make connection to backend: localhost
```

I had to run this on our box. 
```
/usr/sbin/setsebool -P httpd_can_network_connect 1
```


# Source: Integrating Jira with Apache using SSL

https://confluence.atlassian.com/adminjiraserver079/integrating-jira-with-apache-using-ssl-950289045.html
