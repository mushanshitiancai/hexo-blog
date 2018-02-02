---
title: Java日志-Logback在运行时获取日志文件的路径
date: 2016-09-28 10:27:41
categories: [Java]
tags: [java,log]
---

在使用logback的过程中，一般日志目录都是设置为`<property name="LOG_DIR" value="logs"/>`，一般logs目录都会生成在项目根目录中，但是当我用idea的tomcat进行调试web应用是，就发现找不到logs目录了。。。

于是想到了在运行时获取日志文件的位置，参考网上的代码：

```
LoggerContext context = (LoggerContext)LoggerFactory.getILoggerFactory();
for (ch.qos.logback.classic.Logger logger : context.getLoggerList()) {
    for (Iterator<Appender<ILoggingEvent>> index = logger.iteratorForAppenders(); index.hasNext();) {
        Appender<ILoggingEvent> appender = index.next();
        if(appender instanceof FileAppender){
            FileAppender fileAppender = (FileAppender) appender;
            File file = new File(fileAppender.getFile());
            String canonicalPath = file.getCanonicalPath();
            System.out.println(canonicalPath);
        }
    }
}
```

这样就会答应出所有日志文件的路径。

然后我发现日志文件竟然打到了`/usr/local/Cellar/tomcat/8.0.28/libexec/bin/logs/log.log`这里。。。为什么日志会输出到我的tomcat的安装目录的bin下呢？idea在运行的时候会打出运行命令行，我们看一下：`/usr/local/Cellar/tomcat/8.0.28/libexec/bin/catalina.sh run`，可以看到idea在使用tomcat调试时，是调用目标tomcat（根据你设置的tomcat位置）的`catalina.sh`然后执行run命令，所以运行的当前目录成了`catalina.sh`所在的bin目录了。而logback的配置中，配置的是相对目录，会在运行的当前目录下新建logs文件夹，所以就输出到tomcat的bin目录下了。

## 外一篇：输出logback的运行详细信息

```
LoggerContext lc = (LoggerContext) LoggerFactory.getILoggerFactory();
StatusPrinter.print(lc);
```

## 参考资料
- [java - Is it possible to find logback log files programmatically? - Stack Overflow](http://stackoverflow.com/questions/7064402/is-it-possible-to-find-logback-log-files-programmatically)