---
title: 【TODO】mysql查看数据库信息命令
date: 2016-04-12 16:29:21
tags: mysql
---

## show
show命令可以用来查看很多信息。

查看数据库中的所有表：

    show tables;

这个命令需要先使用`use`来选定一个数据库作为当前数据库才




## 查看当前使用的数据库
方法1：

    show tables;

显示的格式是：

```
+---------------------------+
| Tables_in_mysql           |
+---------------------------+
| columns_priv              |
```

`Tables_in_`后面显示的就是当前数据库名字了。

方法2：

    select database();

