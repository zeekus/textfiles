
How to set up SSMTP 

Problem: All mail from the bash shell was ending up in MS365 quarantine. 
All mail from the cron was ending up in quarantine. I got mail to function properly by adding the following:

# 1 Installed package [ [yum|apt] install ssmtp ]
# 2 Set up SSMTP
# 3 Removed symlink for /usr/sbin/sendmail that was going to /etc/alternatives/snedmail.postfix -> /usr/lib/sendmail.postfix [final]
```
rm /usr/sbin/sendmail
```
# 4 Created a symlink from /usr/sbin/sendmail pointing to /usr/sbin/ssmtp
```
ln -s /usr/sbin/ssmtp /usr/sbin/sendmail
```
# 5 Configured /etc/ssmtp/ssmtp.conf

source: https://discourse.roots.io/t/cron-mails-with-wrong-recipient/10163/4

# /etc/ssmtp/ssmtp_conf 

```
root=postmaster
mailhub=mail
TLS_CA_File=/etc/pki/tls/certs/ca-bundle.crt
AuthMethod=Login
FromLineOverride=Yes
UseTLS=Yes
UseSTARTTLS=Yes
hostname=myaws.hostname.example.com
mailhub=email-smtp.us-east-1.amazonaws.com:587
AuthUser=mysmsuser
AuthPass=mysmspass
```

# Description of SSMTP from Man pages 

```
SSMTP(8)                                               System Manager's Manual                                               SSMTP(8)

NAME
       ssmtp, sendmail - send a message using smtp

SYNOPSIS
       ssmtp [ flags ] [ address ... ]
       /usr/lib/sendmail [ flags ] [ address ... ]

DESCRIPTION
       ssmtp  is  a  send-only  sendmail emulator for machines which normally pick their mail up from a centralized mailhub (via pop,
       imap, nfs mounts or other means).  It provides the functionality required for humans and programs to send mail via  the  stan‐
       dard or /usr/bin/mail user agents.

       It  accepts  a mail stream on standard input with recipients specified on the command line and synchronously forwards the mes‐
       sage to the mail transfer agent of a mailhub for the mailhub MTA to process. Failed messages are placed in dead.letter in  the
       sender's home directory.

       Config  files allow one to specify the address to receive mail from root, daemon, etc.; a default mailhub; a default domain to
       be used in From: lines; per-user From: addresses and mailhub names; and aliases in the traditional format used by sendmail for
       the /etc/aliases file.

       It  does not attempt to provide all the functionality of sendmail: it is intended for use where other programs are the primary
       means of at last mail delivery.  It is usefull with pop/imap, or to simulate the Sun shared  mail  spool  option  for  non-Sun
       machines,  for  machines  whose  sendmails are too difficult (or various) to configure, for machines with known disfeatures in
       their sendmails or for ones where there are ``mysterious problems''.

       It does not honor .forwards, which have to be done on the recieving host.  It especially does not deliver to pipelines.
```
