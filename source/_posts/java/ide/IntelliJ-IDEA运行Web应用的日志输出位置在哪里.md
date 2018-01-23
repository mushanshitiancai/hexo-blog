---
title: IntelliJ IDEA运行Web应用的日志输出位置在哪里
date: 2018-01-23 19:55:48
categories: [Java]
tags: [java,idea,tomcat]
---

根据[IntelliJ IDEA中设置Tomcat服务器配置](http://mushanshitiancai.github.io/2017/09/07/java/ide/IntelliJ-IDEA%E4%B8%AD%E8%AE%BE%E7%BD%AETomcat%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE/)，IntelliJ IDEA运行Tomcat时，采用的是安装目录和工作目录分开的模式。

所以日志输出位置也就在工作目录下的logs里了。但是在这个目录里只能找到`localhost_access_log`，`catalina`，`manager`，`host-manager`这些tomcat本身输出的日志，对已应用自己打的日志竟然找不到。

应用使用的是log4j，配置也很简单：

```
log4j.rootLogger=ERROR,L

log4j.logger.L=ERROR
log4j.appender.L=org.apache.log4j.DailyRollingFileAppender
log4j.appender.L.Threshold=ERROR
log4j.appender.L.ImmediateFlush=true
log4j.appender.L.File=logs/error.log
log4j.appender.L.Append=true
log4j.appender.L.BufferedIO=true
log4j.appender.L.BufferSize=4096
log4j.appender.L.DatePattern=yyyy-MM-dd
log4j.appender.L.layout=org.apache.log4j.PatternLayout
log4j.appender.L.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss,SSS} [%5p] - %t - %c -%F(%L) -%m%n
```

日志位置是`logs/error.log`，但是问题是，这里日志输出的相对目录是哪里呢？

这里完整的路径是`{user.dir}/logs/error.log`，所以可以在运行是查看`System.getProperty("user.dir")`得到当前的目录，发现是`Z:\Server\apache-tomcat-7.0.55\bin`，原来是tomcat的可执行目录。。。

因为idea启动应用的方式是`Z:\Server\apache-tomcat-7.0.55\bin\catalina.bat run`，所以当前工作目录是tomcat的bin目录了。

在其中找到了`logs/error.log`

## 参考资料
- [java - Where can i programatically find where the log4j log files are stored? - Stack Overflow](https://stackoverflow.com/questions/3217296/where-can-i-programatically-find-where-the-log4j-log-files-are-stored?rq=1)