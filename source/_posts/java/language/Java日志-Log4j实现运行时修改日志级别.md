---
title: Java日志-Log4j实现运行时修改日志级别
date: 2018-07-28 17:18:54
categories: [Java,掌握Java]
tags: [java,log4j]
toc: true
---

[源码分析](http://imushan.com/2018/07/28/java/language/Java%E6%97%A5%E5%BF%97-Log4j%E6%BA%90%E7%A0%81%E5%88%86%E6%9E%90/)后，实现Log4j运行时修改日志级别思路就非常清晰了。

<!-- more -->

全局的日志级别保存在`org.apache.log4j.Hierarchy#threshold`中，是通过`log4j.threshold`配置项设置的，因我们基本不会配置这个配置项，所以可以不用管。

剩下的日志级别配置在Logger上。我们只要获取对应的Logger，设置其level属性即可：

```java
Logger rootLogger = Logger.getRootLogger();
rootLogger.setLevel(Level.DEBUG);
```

嗯，就是这么简单。
