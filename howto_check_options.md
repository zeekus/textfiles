
# Web server options checks with curl:

```
[ted.knab@jump1p ~]$ curl -k -i -X HEADER OPTIONS https://annapolislinux.org  2>>/dev/null | grep -i ^HTTP
HTTP/1.1 403 Forbidden
[ted.knab@jump1p ~]$ curl -k -i -X HEADER OPTIONS https://washcoll.edu  2>>/dev/null | grep -i ^HTTP
HTTP/1.1 200 OK
[ted.knab@jump1p ~]$ curl -k -i -X HEADER OPTIONS https://www.somesite.gov  2>>/dev/null | grep -i ^HTTP
HTTP/1.0 400 Bad Request
```
