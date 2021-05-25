## ViM cheatsheat worrk in progress.



# add . where there blank spaces to help identify spaces
``` 
:set list
:set listchars+=space:.
```
or

```
:set list :set listchars+=space:.
```

# disable colors

```
:set syntax off
```

# delete range of lines
-:[start_line#],[end_line#]d

example delete lines 3-6:
```
:3,6d
```

# delete all lines before the current line

```
:1, .-1d
```

# delete lines with a pattern

```
:g /deleteme/d
```

# delete lines with a not pattern

``` 
:%g!/deleteme/d
```
or 
```
:v/deleteme/d
```

