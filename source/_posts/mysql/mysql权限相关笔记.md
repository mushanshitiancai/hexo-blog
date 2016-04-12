---
title: mysql权限相关笔记
date: 2016-04-12 22:38:20
tags: mysql
---

## 运行mysql远程访问
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

## 参考资料
- [is not allowed to connect to this MySQL server解决办法-mysql教程-数据库-壹聚教程网](http://www.111cn.net/database/mysql/42040.htm)
- [Host 'XXX' is not allowed to connect to this MySQL server 解决方案/如何开启MySQL的远程帐号 - 宁静.致远 - 博客园](http://www.cnblogs.com/zhangzhu/archive/2013/08/22/3274831.html)


