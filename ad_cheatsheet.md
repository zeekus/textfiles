## Cheat Sheet for AD CMD line tools

# 1. find options for users

```
net user /help
```

# 2. list user

```
net user myuser /domain
```

# 3. activate account 

```
net user myuser /domain /active:yes
```

# 4. deactive user

```
net user myuser /domain /active:no
```

# 5. change the user's password interactively from the command line

```
net user myuser * /domain
```
