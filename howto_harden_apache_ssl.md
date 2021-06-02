
How to harden apache to use better SSL. 

problem: it may be possible to break the encryption on some apache SSL configuations.



From Website: 

```
Run openssl dhparam -out /etc/apache2/dhparams.pem 2048

Edit /etc/apache2/apache.conf

SSLCipherSuite EECDH+AESGCM:AES256+EECDH
SSLProtocol All -SSLv2 -SSLv3
SSLOpenSSLConfCmd DHParameters "/etc/apache2/dhparams.pem"
SSLHonorCipherOrder On
SSLSessionTickets Off
```

source: https://www.farsightsecurity.com/blog/txt-record/hardening-dh-and-ecc-20151202/


# 1. generate the new key

```
cd /etc/pki/tls
openssl dhparam -out dhparams.pem 2048
```

# 2. Configure Apache to use the keys 

If using mod SSL edit: /etc/httpd/conf.d/ssl.conf 

-  set urandom to use 2048

```
SSLRandomSeed startup file:/dev/urandom 2048
SSLRandomSeed connect file:/dev/urandom 2048
```

- use better SSL Ciphers

```
SSLCipherSuite EECDH+AESGCM:AES256+EECDH
```


- use new 'dhparams.pem' key that was created in #1

```
SSLOpenSSLConfCmd "/etc/pki/tls/dhparams.pem"
```

Working example of a more secure ssl file using mod-ssl.

Full file: source /etc/httpd/conf/ssl.conf

```
<IfModule mod_ssl.c>
  SSLRandomSeed startup builtin
  SSLRandomSeed startup file:/dev/urandom 2048
  SSLRandomSeed connect builtin
  SSLRandomSeed connect file:/dev/urandom 2048

  AddType application/x-x509-ca-cert .crt
  AddType application/x-pkcs7-crl    .crl

  SSLPassPhraseDialog builtin
  SSLSessionCache "shmcb:/var/cache/mod_ssl/scache(512000)"
  SSLSessionCacheTimeout 300
  Mutex posixsem
  SSLCryptoDevice builtin
  SSLHonorCipherOrder On
  SSLUseStapling Off
  SSLSessionTickets On
  SSLStaplingCache "shmcb:/run/httpd/ssl_stapling(32768)"
  SSLCipherSuite EECDH+AESGCM:AES256+EECDH
  SSLProtocol all -SSLv2 -SSLv3
  SSLOptions StdEnvVars
  SSLOpenSSLConfCmd "/etc/pki/tls/dhparams.pem"
</IfModule>
```