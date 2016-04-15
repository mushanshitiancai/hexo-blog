---
title: mysql权限相关笔记
date: 2016-04-12 22:38:20
tags: mysql
---

[MySQL :: MySQL 5.7 Reference Manual :: 7.2 The MySQL Access Privilege System](http://dev.mysql.com/doc/refman/5.7/en/privilege-system.html)

## 允许mysql远程访问
安装mysql后，远程访问这个机子的mysql服务，提示错误：

    $ mysql -h192.168.33.10 -P 3306 -u root -p111
    ERROR 1130 (HY000): Host '192.168.33.10' is not allowed to connect to this MySQL server

这是因为mysql对于什么用户可以从什么host来访问数据库是有严格的限制的。

我们可以查看目前数据库中用户，已经用户可以从什么host访问的信息，本机登入mysql：

```
mysql> use mysql;
Database changed

mysql> select user,host from user;
+------+-----------------------+
| user | host                  |
+------+-----------------------+
| root | 127.0.0.1             |
|      | localhost             |
| root | localhost             |
|      | localhost.localdomain |
| root | localhost.localdomain |
+------+-----------------------+
5 rows in set (0.00 sec)
```

可以看到目前只有root用户，只能从'127.0.0.1'或者'localhost'来访问数据库。

可以授予root用户可以在其他host访问数据库的权限：

```
mysql> grant all privileges on *.* to 'root' @'192.168.33.10' identified by '222' with grant option;
Query OK, 0 rows affected (0.00 sec)
```

然后就可以在外部连接这个数据库了：

    $ mysql -h192.168.33.10 -P 3306 -u root -p222

## 为什么什么权限也没有但是还是可以查询增删改查？
安装好mysql后，我发现可以使用空账号登录mysql。

- [mysql - Only "grant usage", but can still select, drop, create? - Database Administrators Stack Exchange](http://dba.stackexchange.com/questions/66584/only-grant-usage-but-can-still-select-drop-create)


## 什么是否需要`flush privileges`

>    MySQL 的权限系统在实现上比较简单，相关权限信息主要存储在几个被称为grant tables 的系统表中，即： mysql.User，mysql.db，mysql.Host，mysql.table_priv 和mysql.column_priv。由于权限信息数据量比较小，而且访问又非常频繁，所以Mysql 在启动的时候，就会将所有的权限信息都Load 到内存中保存在几个特定的结构中。所以才有我们每次手工修改了权限相关的表之后，都需要执行FLUSH PRIVILEGES命令重新加载MySQL的权限信息。当然，如果我们通过GRANT，REVOKE 或者DROP USER 命令来修改相关权限，则不需要手工执行FLUSH PRIVILEGES 命令，因为通过GRANT，REVOKE 或者DROP USER 命令所做的权限修改在修改系统表的同时也会更新内存结构中的权限信息。在MySQL5.0.2 或更高版本的时候，MySQL 还增加了CREATE USER 命令，以此创建无任何特别权限（仅拥有初始USAGE权限）的用户，通过CREATE USER 命令创建新了新用户之后，新用户的信息也会自动更新到内存结构中。所以，建议读者一般情况下尽量使用GRANT，REVOKE，CREATE USER 以及DROPUSER 命令来进行用户和权限的变更操作，尽量减少直接修改grant tables 来实现用户和权限变更的操作。
> [MySQL的权限系统简析 - mysql数据库栏目 - 红黑联盟](http://www.2cto.com/database/201208/147469.html)

## 参考资料
- [is not allowed to connect to this MySQL server解决办法-mysql教程-数据库-壹聚教程网](http://www.111cn.net/database/mysql/42040.htm)
- [Host 'XXX' is not allowed to connect to this MySQL server 解决方案/如何开启MySQL的远程帐号 - 宁静.致远 - 博客园](http://www.cnblogs.com/zhangzhu/archive/2013/08/22/3274831.html)


