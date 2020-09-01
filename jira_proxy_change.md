# How to change the proxy from AJP/1.3 to mod_proxy 

# Problem

Jira uses a proxy. With Jira 8.11.0 the legacy AJP/1.3 proxy stops working.
Also, There is the ghost cat vulerability. 
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


# Source: Intergrating Jira with Apache using SSL

https://confluence.atlassian.com/adminjiraserver079/integrating-jira-with-apache-using-ssl-950289045.html
