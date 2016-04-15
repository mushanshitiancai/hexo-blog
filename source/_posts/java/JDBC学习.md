---
title: JDBC学习
date: 2016-04-07 17:07:44
tags: java
---

## 新建一个jdbc工程
新建一个jdbc demo来体验一下流程。

前提准备：
- 虚拟机中安装mysql，虚拟机IP：192.168.33.10
- 建立可以远程访问的用户mushan，密码111(演示用)

上面的操作可以参考：[安装配置mysql | 木杉的博客](http://mushanshitiancai.github.io/2016/04/10/mysql/%E5%AE%89%E8%A3%85%E9%85%8D%E7%BD%AEmysql/)

用maven建立一个jdbc工程：

```
$ mvn archetype:generate -B -DarchetypeGroupId=org.apache.maven.archetypes -DarchetypeArtifactId=maven-archetype-quickstart -DgroupId=com.mushan -DartifactId=mvn-jdbc-test -Dversion=0.0.1SHNAPSHOT -Dpackage=com.mushan
```

也可以在eclispe中创建maven工程，更方便。

添加mysql驱动程序依赖：

```
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>5.1.38</version>
</dependency>
```

连接数据库流程
- 初始化数据库驱动
- 使用`DriverManager.getConnection()`建立到数据库的连接
- 使用`connection.createStatement()`建立



## 参考资料
- [在eclipse导入Java 的jar包的方法 JDBC【图文说明】 - 陶伟基Wiki - 博客园](http://www.cnblogs.com/taoweiji/archive/2012/12/11/2812295.html)
