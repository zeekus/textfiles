
## Powershell cheatsheet


# Search for disabled accounts

```
Search-ADAccount -AccountDisabled |ft
```

# Find accounts that never expire

```
Search-adaccount -passwordneverExpires | ft
```

# Find users only

```
Search-ADAccount -UserOnly
```

# Find locked out acccounts
```
Search-ADAccount -LockedOut
```

# Find accounts inactive in 90 days
```
Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 | Format-Table Name,ObjectClass -A
```

# Find all users,computers, and service accounts that are disabled

```
Search-ADAccount -AccountDisabled | Format-Table Name,ObjectClass -A
```



# Find users and emails of users that are enabled and accounts that expire. 


```
Get-ADUser -Filter {Enabled -eq $true  -and PasswordNeverExpires -eq $false } -Properties 'msDS-UserPasswordExpiryTimeComputed', 'mail' | Format-Table Name,mail,ObjectClass -A
```

# Find users with no email

```
get-aduser -filter * -properties * | where {!$_.emailaddress} | select-object samaccountname
```


# Find uses with no emails and get thee objects

```
get-aduser  -filter * -properties * | where {!$_.emailaddress} | select-object samaccountname,name,distinguishedname 
```

# get epoch unit time on Windows

```
powershell -command "(New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds"
```