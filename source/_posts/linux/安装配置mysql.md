---
title: 安装配置mysql
date: 2016-04-10 09:31:14
tags: linux
---

记录一下mysql在centos6.6上的安装与配置。

<!-- more -->

## 安装

    $ yum install -y mysql-server mysql mysql-deve

启动服务

    $ service mysqld start

提示错误：

    mysqld starten:                                            [FEHLGESCHLAGEN]

因为需要`sudo`，第一次启动会进行初始化：

```
$ sudo service mysqld start
MySQL-Datenbank initialisieren:  Installing MySQL system tables...
OK
Filling help tables...
OK

To start mysqld at boot time you have to copy
support-files/mysql.server to the right place for your system

PLEASE REMEMBER TO SET A PASSWORD FOR THE MySQL root USER !
To do so, start the server, then issue the following commands:

/usr/bin/mysqladmin -u root password 'new-password'
/usr/bin/mysqladmin -u root -h localhost.localdomain password 'new-password'

Alternatively you can run:
/usr/bin/mysql_secure_installation

which will also give you the option of removing the test
databases and anonymous user created by default.  This is
strongly recommended for production servers.

See the manual for more instructions.

You can start the MySQL daemon with:
cd /usr ; /usr/bin/mysqld_safe &

You can test the MySQL daemon with mysql-test-run.pl
cd /usr/mysql-test ; perl mysql-test-run.pl

Please report any problems with the /usr/bin/mysqlbug script!

                                                           [  OK  ]
mysqld starten:                                            [  OK  ]
```


其中有一段：

```
PLEASE REMEMBER TO SET A PASSWORD FOR THE MySQL root USER !
To do so, start the server, then issue the following commands:

/usr/bin/mysqladmin -u root password 'new-password'
/usr/bin/mysqladmin -u root -h localhost.localdomain password 'new-password'
```

这是提示我们设置默认密码的。照做即可。

然后登陆mysql：

    $ mysql -u root -p

## 启动
mysql官方推荐使用`mysqld_safe`来启动mysqld服务，这个脚本做了更多的工作，包括打日志，遇到错误自动重启mysql等。

    mysqld_safe --user=mysql &

不过我在mysql文档中没有找到如何使用`mysqld_safe`来关闭mysqld服务。

[启动、停止、重启 MySQL 常见的操作方法](http://blog.csdn.net/aeolus_pu/article/details/9300205)这篇文章中提到了几种停止mysql的方法：

- 使用 service 启动：service mysqld stop
- 使用 mysqld 脚本启动：/etc/inint.d/mysqld stop
- mysqladmin shutdown

我选择的是`mysqladmin shutdown`

## 自动启动



## 参考资料
- [CentOs中mysql的安装与配置 - 发表是最好的记忆 - 博客园](http://www.cnblogs.com/shenliang123/p/3203546.html)
- [MySQL :: MySQL 5.7 Reference Manual :: 2.10.5 Starting and Stopping MySQL Automatically](http://dev.mysql.com/doc/refman/5.7/en/automatic-start.html)
- [mysql安全启动脚本mysqld_safe详细介绍_Mysql_脚本之家](http://www.jb51.net/article/52259.htm)
- [手动安装mysql，使用mysqld_safe启动mysql服务 - san_yun - ITeye技术网站](http://san-yun.iteye.com/blog/1493931)
- [Linux下chkconfig命令详解 - 小顾问 - 博客园](http://www.cnblogs.com/panjun-Donet/archive/2010/08/10/1796873.html)
- [启动、停止、重启 MySQL 常见的操作方法： - aeoluspu的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/aeolus_pu/article/details/9300205)