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

运行`mvn package`安装依赖。

一次完整的数据库操作流程：
- 初始化数据库驱动
- 使用`DriverManager.getConnection()`建立到数据库的连接
- 使用`connection.createStatement()`建立语句类实例(Statement)
- 使用`statement.executeQuery()`执行SQL语句获取ResultSet对象实例
- 从ResultSet对象实例中获取结果

简化版：获取连接→创建Statement→执行数据库操作→获取结果→关闭Statement→关闭结果集→关闭连接。

**问题：** 关闭Statement→关闭结果集→关闭连接，这个顺序是固定的么？


对应的代码如下：

```
package com.mushan;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class App 
{
    public static void main( String[] args ) throws ClassNotFoundException, SQLException
    {
    Class.forName("com.mysql.jdbc.Driver");
    String url="jdbc:mysql://192.168.33.10:3306/jdbc_test";
    String user="mushan";//用户名
    String pwd="111";//密码
    Connection con=DriverManager.getConnection(url,user,pwd);
    Statement stmt = con.createStatement();
    ResultSet rs = stmt.executeQuery("show tables;");//查询,返回结果集
    while(rs.next()){
        System.out.println(rs.getString(1));
    }

    rs.close();
    stmt.close();
    con.close();
    }
}
```

运行代码：

    $ mvn compile
    $ mvn exec:java -Dexec.mainClass="com.mushan.App"  -Dexec.cleanupDaemonThreads=false

输出`jdbc_test`中的表。成功！

之后改用IDE了，直接命令行写Java太麻烦了。

**问题：**
- executeQuery()中的SQL语句可以不加分号么?

  可以

- statement对象可以复用么（进行多次查询）？

  可以

## jdbc api
jdbc主要的接口有：

- java.sql.DriverManager
- java.sql.Connection
- java.sql.Statement
- java.sql.ResultSet
- java.sql.PreparedStatement
- java.sql.CallableStatement
- java.sql.SQLException
- java.sql.SQLWarning
- java.sql.Time
- java.sql.Timestamp
- java.sql.Types
- java.sql.DatabaseMetaData

### java.sql.DriverManager
驱动管理。可以用DriverManager来获取具体的数据库驱动。

### java.sql.Connection
数据库驱动建立连接后获取的连接对象，可以用连接对象获取Statement对象，进行进行数据库操作。

常用方法：
- close()                      关闭连接
- commit()                     提交（事务？）
- rollback()                   回滚（事务？）
- createStatement()            创建Statement对象
- prepareStatement(String sql) 返回PrepareStatement对象
- setAutoCommit(Boolean autoCommit) 设置是否自动提交

### java.sql.Statement

常用方法：
- close()                     关闭Statement对象
- executeQuery(String sql)    执行查询sql，返回ResultSet对象
- executeUpdate(String sql)   执行更新sql，返回更新的行数
- execute(String sql)         执行任意sql，返回bool值，表示是否返回了ResultSet对象
- getResultSet()              获取ResultSet对象

**问题：**
- executeQuery()执行更新操作是什么下场？
- executeUpdate()执行查询操作是什么下场？
- getResultSet()只会返回execute()的结果么？

### java.sql.ResultSet
### java.sql.PreparedStatement
### java.sql.CallableStatement



## 参考资料
- 《Java数据库详解》
- [在eclipse导入Java 的jar包的方法 JDBC【图文说明】 - 陶伟基Wiki - 博客园](http://www.cnblogs.com/taoweiji/archive/2012/12/11/2812295.html)
