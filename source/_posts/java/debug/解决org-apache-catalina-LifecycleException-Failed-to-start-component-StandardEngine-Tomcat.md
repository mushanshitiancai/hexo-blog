---
title: '解决org.apache.catalina.LifecycleException: Failed to start component [StandardEngine[Tomcat]'
date: 2016-08-04 11:32:34
categories: [Java]
tags: [java]
---

用maven的tomcat插件运行Java web项目时遇到一个错误：

```
java.util.concurrent.ExecutionException: org.apache.catalina.LifecycleException: Failed to start component [StandardEngine[Tomcat].StandardHost[localhost].StandardContext[]]
```

一路缩小范围，发现竟然是在进入了servlet和Spring依赖之后出现的问题：

```
<dependencies>
    <dependency>
        <groupId>javax.servlet</groupId>
        <artifactId>javax.servlet-api</artifactId>
        <version>3.0.1</version>
    </dependency>
    <dependency>
        <groupId>javax.servlet.jsp</groupId>
        <artifactId>jsp-api</artifactId>
        <version>2.2</version>
    </dependency>
    <dependency>
        <groupId>javax.servlet</groupId>
        <artifactId>jstl</artifactId>
        <version>1.2</version>
    </dependency>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-webmvc</artifactId>
        <version>${spring.version}</version>
    </dependency>
</dependencies>
```

设置javax.servlet-api的依赖范围为`provided`，就没问题了。servlet的依赖必须是provided，因为容器会提供这些依赖，如果你在打包时还附带了这些依赖，可能就会出现问题。

## 参考资料
- [servlets - java.lang.ClassNotFoundException: HttpServletRequest - Stack Overflow](http://stackoverflow.com/questions/10556201/java-lang-classnotfoundexception-httpservletrequest)