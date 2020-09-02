# how to troubleshoot nagios plugins on Centos 8


# checking mailq

**install the nagios module** 

```
dnf install nagios-plugins-mailq
```

**test from remote nagios server**
```
[ted.knab@nagios0p ~]$  /usr/lib64/nagios/plugins/check_nrpe -H nagios_client1 -c check_mailq
NRPE: Unable to read output
```

**tail logs on nagios client**
```
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[1]: Started User Manager for UID 0.
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net sudo[380836]: pam_unix(sudo:session): session opened for user root by (uid=0)
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net postfix/sendmail[380849]: warning: /etc/postfix/main.cf, line 104: overriding earlier entry: unverified_sender_reject_code=550
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net postfix/postqueue[380849]: warning: /etc/postfix/main.cf, line 104: overriding earlier entry: unverified_sender_reject_code=550
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net postfix/showq[380850]: warning: /etc/postfix/main.cf, line 104: overriding earlier entry: unverified_sender_reject_code=550
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net sudo[380836]: pam_unix(sudo:session): session closed for user root
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[1]: user-runtime-dir@0.service: Unit not needed anymore. Stopping.
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[1]: Stopping User Manager for UID 0...
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[380839]: Stopped target Default.
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[380839]: Stopped target Basic System.
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[380839]: Stopped target Sockets.
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[380839]: Closed D-Bus User Message Bus Socket.
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[380839]: Stopped target Paths.
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[380839]: Reached target Shutdown.
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[380839]: Stopped target Timers.
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[380839]: Starting Exit the Session...
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[1]: user@0.service: Killing process 380852 (systemctl) with signal SIGKILL.
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[1]: user-runtime-dir@0.service: Unit not needed anymore. Stopping.
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[1]: Stopped User Manager for UID 0.
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[1]: user-runtime-dir@0.service: Unit not needed anymore. Stopping.
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[1]: Stopping /run/user/0 mount wrapper...
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[1]: Removed slice User Slice of UID 0.
Sep 02 11:54:30 nagios_client1.us-east.aws.example.net systemd[1]: Stopped /run/user/0 mount wrapper.
Sep 02 11:54:33 nagios_client1.us-east.aws.example.net dbus-daemon[768]: [system] Activating service name='org.fedoraproject.Setroubleshootd' requested by ':1.209' (uid=0 pid=687 comm="/usr/sbin/sedispatch " label="system_u:system_r:auditd_t:s0") (using servicehelper)
Sep 02 11:54:33 nagios_client1.us-east.aws.example.net dbus-daemon[380860]: [system] Failed to reset fd limit before activating service: org.freedesktop.DBus.Error.AccessDenied: Failed to restore old fd limit: Operation not permitted
Sep 02 11:54:33 nagios_client1.us-east.aws.example.net dbus-daemon[768]: [system] Successfully activated service 'org.fedoraproject.Setroubleshootd'
Sep 02 11:54:34 nagios_client1.us-east.aws.example.net setroubleshoot[380860]: Deleting alert a4cc881e-6603-45fd-aa0a-266c6f5660ff, it is allowed in current policy
Sep 02 11:54:34 nagios_client1.us-east.aws.example.net setroubleshoot[380860]: SELinux is preventing check_mailq from getattr access on the file /usr/sbin/postfix. For complete SELinux messages run: sealert -l c6004f2d-da29-4b95-a0f5-4d56edb9888d
Sep 02 11:54:34 nagios_client1.us-east.aws.example.net platform-python[380860]: SELinux is preventing check_mailq from getattr access on the file /usr/sbin/postfix.

                                                                              *****  Plugin catchall (100. confidence) suggests   **************************

                                                                              If you believe that check_mailq should be allowed getattr access on the postfix file by default.
                                                                              Then you should report this as a bug.
                                                                              You can generate a local policy module to allow this access.
                                                                              Do
                                                                              allow this access for now by executing:
                                                                              # ausearch -c 'check_mailq' --raw | audit2allow -M my-checkmailq
                                                                              # semodule -X 300 -i my-checkmailq.pp

```

**fix selinux on client server nagios_client1**

```
  ausearch -c 'check_mailq' --raw | audit2allow -M my-checkmailq
  semodule -X 300 -i my-checkmailq.pp
```

**test again from nagios server**

```
[ted.knab@nagios0p ~]$  /usr/lib64/nagios/plugins/check_nrpe -H nagios_client1 -c check_mailq
OK: sendmail mailq is empty|unsent=0;5;10;0
```