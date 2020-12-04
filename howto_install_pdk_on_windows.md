# HOW TO INSTALL PDK ON WINDOWS10

# installing PDK on windows requires Chocoatey

source: https://chocolatey.org/install

source: https://puppet.com/docs/pdk/1.x/pdk_install.html

# get install script

```
wget https://chocolatey.org/install.ps1
```

# open powershell terminal as admin

# set execution policy to allowed
*source: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.1*
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

# run the instlall.ps1 script

```
cd mysave_dir
rename install.ps1.txt install.ps1
./install.ps1
```

# verify it was installed properly

```
choco upgrade chocolatey --pre 
```

# install pdk

```
choco install pdk
```