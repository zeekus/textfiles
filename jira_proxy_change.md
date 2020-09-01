# How to change the proxy on Jira when using apache 2.4

# Problem

Jira uses a proxy. With Jira 8.11.0 the legacy proxy stops working.

# Fix: switch from AJP/1.3 to http proxy

## Part 1: Reconfigure Jira to use httpd proxy - server.xml diffs
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

## Part 2: Reconfigure Apache 2.4 to use httpd proxy jira_ssl.conf

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



# Source: Intergrating Jira with Apache using SSL

https://confluence.atlassian.com/adminjiraserver079/integrating-jira-with-apache-using-ssl-950289045.html
