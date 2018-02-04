---
title: Java日志-MDC的使用
date: 2018-02-02 14:28:16
categories: [Java]
tags: [java,log]
---

MDC（Mapped Diagnostic Context，映射调试上下文，是Log4J/Logback提供的在多线程环境下打印日志的工具。其前身是NDC（Nested Diagnostic Context），NDC是 Neil Harrison 在名为《 Patterns for Logging Diagnostic Messages 》的书中提出的嵌套诊断环境的机制。这种机制的提出，主要为了减少多线程的系统为每个客户单独记录日志的系统开销。

比如在Java Web中，每个请求由独立的线程处理，如果要在处理过程的日志中打印这个请求的用户信息，一般的做法是把用户信息从Controller层一路往下传到Service层，Dao层等等，那所有的函数都需要添加一个UserInfo的参数，是非常不灵活的。MDC可以用来保存这类信息，MDC为每个线程保存一个Map，可以在Map中添加信息，然后在日志中输出。

我看到这个介绍时，心想这个和ThreadLocal功能不是一样的么？的确，MDC就是基于ThreadLocal机制实现的。

<!--more-->

## 使用



## 参考资料
- [Java Logging with Mapped Diagnostic Context (MDC) | Baeldung](http://www.baeldung.com/mdc-in-log4j-2-logback)
- [MDC介绍 -- 一种多线程下日志管理实践方式 - CSDN博客](http://blog.csdn.net/sunzhenhua0608/article/details/29175283)
- [在 Web 应用中增加用户跟踪功能](https://www.ibm.com/developerworks/cn/web/wa-lo-usertrack/index.html#fig1)
- [使用 Log4j 的 NDC/MDC 改进日志 - 八月下沙](https://my.oschina.net/mays/blog/671849)
- [Introduction to Spring MVC HandlerInterceptor | Baeldung](http://www.baeldung.com/spring-mvc-handlerinterceptor)
- [SpringMVC的拦截器（Interceptor）和过滤器（Filter）的区别与联系 - xiaoyaotan_111的博客 - CSDN博客](http://blog.csdn.net/xiaoyaotan_111/article/details/53817918)