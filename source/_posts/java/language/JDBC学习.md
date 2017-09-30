---
title: JDBC学习
date: 2016-04-07 17:07:44
categories: [Java]
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

```xml
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

**问题：** 【TODO】 `关闭Statement→关闭结果集→关闭连接`，这个顺序是固定的么？我在别的地方看到了`关闭结果集→关闭Statement→关闭连接`，哪个是对的？

对应的代码如下：

```java
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

        Exception in thread "main" java.sql.SQLException: Can not issue data manipulation statements with executeQuery().

    也就是说，不行。

- executeUpdate()执行查询操作是什么下场？

        Exception in thread "main" java.sql.SQLException: Can not issue SELECT via executeUpdate() or executeLargeUpdate().

    也就是说，不行。

- getResultSet()只会返回execute()的结果么？

    四种情况：
    - 获得Statement后直接getResultSet  - null
    - 执行executeQuery后getResultSet  - 无论executeQuery结果如何，都是空结果集
    - 执行executeUpdate后getResultSet - null
    - 执行execute后getResultSet       - 如果是查询语句，null，如果是更新语句，则是返回的结果集

### java.sql.PreparedStatement
PreparedStatement是预编译的Statement对象。因为是预编译，所以效率高一点。也是因为这个，所以在获取语句对象的时候就要指定sql语句。对于语句中的变量，可以使用`?`来占位，之后再设置为具体的值。

常用方法：
- close()            关闭连接
- executeQuery()     执行查询sql，返回ResultSet对象
- executeUpdate()    执行更新sql，返回更新的行数
- execute()          执行任意sql，返回bool值，表示是否返回了ResultSet对象
- setBoolean(int paramIndex, boolean x)    替换?指定的参数，paramIndex指定是第几个?
- set...                                   不同类型有不同的set函数
- setDate(int paramIndex, java.sql.Date x) 
- setTime(int paramIndex, java.sql.Time x)
- setObject(int paramIndex, Object x)

**问题：**
- 不设置参数执行会遇到什么问题？

        Exception in thread "main" java.sql.SQLException: No value specified for parameter 1

### java.sql.CallableStatement
CallableStatement是用来调用存储过程的。

### java.sql.ResultSet

常用方法：
- next()
- getInt()

## 关闭连接
参考：[JDBC数据库连接池connection关闭后Statement和ResultSet未关闭的问题 - k1121 - ITeye技术网站](http://k1121.iteye.com/blog/1279063)

根据JDBC规范：

> JDBC. 4.0 Specification——13.1.4 Closing Statement Objects 
> 
> An application calls the method Statement.close to indicate that it has finished processing a statement. All Statement objects will be closed when the connection that created them is closed. However, it is good coding practice for applications to close statements as soon as they have finished processing them. This allows any external resources that the statement is using to be released immediately. 
> 可以通过Statement.close来显式关闭statement。让创建statement的连接关闭后，所有对应的statement都会被关闭。但是在使用完statement后就关闭他们是最佳实践，因为这样可以释放statement占用的外部资源。
> 
> Closing a Statement object will close and invalidate any instances of ResultSet produced by that Statement object. The resources held by the ResultSet object may not be released until garbage collection runs again, so it is a good practice to explicitly close ResultSet objects when they are no longer needed. 
> 关闭Statement对象会关闭这个statement对象创建的所有ResultSet对象。但是ResultSet对象持有的资源会在下一次垃圾回收的时候才会被释放。所以在使用完后就关闭ResultSet对象是一个最佳实践。
> 
> Once a Statement has been closed, any attempt to access any of its methods with the exception of the is Closed or close methods will result in a SQLException being thrown. 
> 一旦Statement被关闭，操作他的有些方法会抛出SQLException。
> 
> These comments about closing Statement objects apply to PreparedStatement and CallableStatement objects as well. 
> 上面说的对于PreparedStatement和CallableStatement同样适用。

**问题：**
- 通过Statement关闭而关闭ResultSet不会释放资源是什么志愿。和主动close ResultSet不一样？
- `any attempt to access any of its methods with the exception of the is Closed or close methods will result in a SQLException being thrown`这句话说close也会触发异常，但是其实不会，为什么。

例子：如果你在关闭了Statement后继续操作之前生成的ResultSet就会触发异常：

    Exception in thread "main" java.sql.SQLException: Operation not allowed after ResultSet closed

一个关闭连接的良好例子：

```
public static void close(Connection con,Statement stmt,ResultSet rs){
    if(rs != null){
        try {
            rs.close();      // 关闭结果集
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if(stmt != null){
                try {
                    stmt.close();    // 关闭
                }catch (SQLException e){
                    e.printStackTrace();
                } finally {
                    if(con != null){
                        try {
                            con.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                }
            }
        }
    }
}
```


## 参考资料
- 《Java数据库详解》
- [在eclipse导入Java 的jar包的方法 JDBC【图文说明】 - 陶伟基Wiki - 博客园](http://www.cnblogs.com/taoweiji/archive/2012/12/11/2812295.html)
- [Java SE 7 Java Database Connectivity (JDBC)-related APIs & Developer Guides](http://docs.oracle.com/javase/7/docs/technotes/guides/jdbc/)
