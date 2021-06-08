# mysql cheat sheet

# 1 connect to the database

**MYSQL on the local machine**
```
mysql -u dbuser -p'password'
```

**MYSQL in AMAZON RDS**
```
mysql -u dbuser -p'pasword' -h myinstance.something.us-east-1.rds.amazonaws.com
```

# 2 check the database uptime

```
MySQL [(none)]> select TIME_FORMAT(SEC_TO_TIME(VARIABLE_VALUE ),'%Hh %im') as Uptime from performance_schema.global_status where VARIABLE_NAME='Uptime';
+---------+
| Uptime  |
+---------+
| 00h 02m |
+---------+
1 row in set (0.00 sec)
```

# 3 check pararmaters in the database 

**check the innoddb_log_file_size**

```
MySQL [(none)]> SELECT @@innodb_log_file_size;
+------------------------+
| @@innodb_log_file_size |
+------------------------+
|             2147483648 |
+------------------------+
1 row in set (0.00 sec)
```