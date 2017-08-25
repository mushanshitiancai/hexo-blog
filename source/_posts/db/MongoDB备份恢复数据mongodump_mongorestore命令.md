---
title: MongoDB备份恢复数据mongodump/mongorestore命令
date: 2017-08-23 17:29:47
categories: MongoDB
tags: [db,mongodb]
---

备份和恢复操作是操作数据库时经常使用的操作。MongoDB提供了mongodump/mongorestore来进行备份和恢复数据。

<!--more-->

## 备份数据

### 备份数据库

```
$ mongodump -h 127.0.0.1:27017 -d 数据库名 -o 输出目录
```

假设数据库为test_d，其中有两个collection，分别为xx，zz，那么导出后的文件夹结构为：

```
/mnt/d/out2
└── test_d
    ├── xx.bson
    ├── xx.metadata.json
    ├── zz.bson
    └── zz.metadata.json
```

### 备份集合

```
$ mongodump -h 127.0.0.1:27017 -d 数据库名 -c collection名称 -o 输出目录
```

假设数据库为test_d，其中有两个collection，分别为xx，zz，指定导出xx，那么导出后的文件夹结构为：

```
/mnt/d/out
└── test_d
    ├── xx.bson
    └── xx.metadata.json
```

## 恢复数据

### 恢复数据库

```
$ mongorestore -h 127.0.0.1:27017 -d 恢复到的数据库名 输出目录/数据库名
```

### 恢复集合

```
$ mongorestore -h 127.0.0.1:27017 -d 恢复到的数据库名 -c 恢复到的collection名称 输出目录/数据库名/collection名称.bson
```

## 速度

机器配置：
- CPU：Intel Xeon E5-2630*2
- 内存：32G
- 硬盘300G*8

我在机器上备份一个1亿5千万条的数据使用了10分钟的时间，速度还是很快的。备份后的文件有79G。

但是恢复数据使用了两个半小时，恢复的速度比备份的速度慢了15倍。。。