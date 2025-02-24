# Setting up Software WAF OWASP with ModSecurity

## Prerequisites
- Nginx or Apache web server
- ModSecurity installed

## Installation Steps

### 1. Initial Setup
```bash
sudo mkdir -p /etc/nginx/modsec
sudo cp /opt/ModSecurity/unicode.mapping /etc/nginx/modsec
sudo cp /opt/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
```

### 2. Install OWASP Core Rule Set
```bash
git clone https://github.com/coreruleset/coreruleset /usr/local/modsecurity-crs
```

### 3. Configure ModSecurity with OWASP
Create `/etc/nginx/modsec/main.conf`:
```bash
Include /etc/nginx/modsec/modsecurity.conf
Include /usr/local/modsecurity-crs/crs-setup.conf
Include /usr/local/modsecurity-crs/rules/*.conf
```

### 4. Configure Nginx Site
Edit `/etc/nginx/sites-available/default`:
```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name _;

    location / {
        modsecurity on;
        modsecurity_rules_file /etc/nginx/modsec/main.conf;
        proxy_redirect off;
    }
}
```

### 5. Setup CRS Configuration
```bash
sudo cp /usr/local/modsecurity-crs/crs-setup.conf.example /usr/local/modsecurity-crs/crs-setup.conf
```

### 6. Set Permissions
```bash
sudo chown -R root:root /usr/local/modsecurity-crs
sudo chmod -R 644 /usr/local/modsecurity-crs
```

### 7. Enable ModSecurity
Edit `/etc/nginx/modsec/modsecurity.conf`:
```bash
SecRuleEngine On
```

## Reference
For more detailed information, visit:
[Nginx WAF with ModSecurity and OWASP CRS Documentation](https://docs.nginx.com/nginx-waf/admin-guide/nginx-plus-modsecurity-waf-owasp-crs/)
[CRS-WORKS] https://coreruleset.org/docs/2-how-crs-works/2-4-sampling_mode/


