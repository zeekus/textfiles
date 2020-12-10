# File: create a symlink to /etc/issue from /etc/issue.net

```
 file { '/etc/issue':
    ensure => 'link',
    target => '/etc/issue.net',
  }
```

```
[myuser@myhost1p ~]$ ls -lah /etc/is*
lrwxrwxrwx. 1 root root   14 Dec  9 16:29 /etc/issue -> /etc/issue.net
-rw-r--r--. 1 root root 1.4K Dec  9 16:28 /etc/issue.net
```

# File: install an RPM from a local file.

```
#simple
packages { "/var/tmp/myfile.rpm":
    provider => 'rpm',
    ensure   => present,
}
```

```
#standard with modifed package name for debugging
  package { "install myfile.rpm":
    provider => 'rpm',
    ensure   => present,
    source   => "/var/tmp/myfile.rpm",
  }
```

```
  #install rpm using outside variables  
  package { "install ${mymodule::config::binary_filename}":
    provider => 'rpm',
    ensure   => present,
    source   => "${mymodule::config::filepath}",
  }
```


# Notify: standard notify message

```
  notify { "debug: hello world":}
```

# Nofify: with variables from a different class 

```
  notify { "debug: install class ${mymodule::config::binary_filename}":}
```


# Passing variables in puppet and basic logic

```
  #filename: config.pp
  #path: mymodule/manifest/config.pp
  class mymodule::config {
    $binary_url='https://s3.amazonaws.com/amazoncloudwatch-agent/centos/amd64/latest/amazon-cloudwatch-agent.rpm'  #64bit binary
	  $binary_filename='amazon-cloudwatch-agent.rpm'
	  $filepath="/var/tmp/${binary_filename}"
  } 
  
  #filename: install.pp
  #path: mymodule/manifest/install.pp
  class mymodule::install { 
    #install rpm 
    package { "install ${mymodule::config::binary_filename}":
      provider => 'rpm',
      ensure   => present,
      source   => "${mymodule::config::filepath}",
    }
  }
  
  #filename: service.pp
  #path: mymodule/manifest/service.pp
  class mymodule::service {
    service { 'myservice':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
   }
  } 
  
  #filename: init.pp
  #path: module/manifest/init.pp
  class mymodule { 
    contain mymodule::config
	contain mymodule::install
	contain mymodule::service
	
  Class['::mymodule::config']
  -> Class['::mymodule::install']
  ~> Class['::mymodule::install']
  }
```     


