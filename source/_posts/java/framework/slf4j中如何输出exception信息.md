---
title: slf4j中如何输出exception信息
date: 2016-10-11 11:10:17
categories: [Java]
tags: java
---

在代码中看到了类似的句子：

```
logger.error("Task: Date={} Create Task ERROR!",date,e);
```

这个日志语句是写在catch子句中的，这里的e是一个Exception实例。这里我就暗笑了一下，明明后面需要输出两个参数，但是前面的字符串只有一个占位符，那么关键的Exception信息岂不是丢掉了么。

然而我在日志文件还是看到了错误信息，这是为什么？

原来slf4j如果发现后面的最后一个参数是一个exception，那么就不会把他添加到错误字符串中，而是会把错误信息追加这条日志后面。

我们，可以做一个实验：

```
logger.error("hello {} ","world","2");
logger.error("hello {} ","world",new RuntimeException("fuck"));
logger.error("hello {} e:{}","world",new RuntimeException("fuck"));

logger.info("hello {} ","world",new RuntimeException("fuck"));
logger.info("hello {} e:{}","world",new RuntimeException("fuck"));
```

输出：

```
2016-10-11 11:09:21 [main] ERROR Main - hello world 
2016-10-11 11:09:21 [main] ERROR Main - hello world 
java.lang.RuntimeException: fuck
    ...
2016-10-11 11:09:21 [main] ERROR Main - hello world e:{}
java.lang.RuntimeException: fuck
    ...
2016-10-11 11:09:21 [main] INFO  Main - hello world 
java.lang.RuntimeException: fuck
    ...
2016-10-11 11:09:21 [main] INFO  Main - hello world e:{}
java.lang.RuntimeException: fuck
    ...
```

第一个例子是如果最后一个参数不是exception，而是普通的对象的话，没有对应的占位符，slf4j就不会输出。而如果最后一个参数是exception，就算有占位符，也不会消费，所以直接输出了`{}`。


## 参考资料
- [java - How to log exception and message with placeholders with SLF4J - Stack Overflow](http://stackoverflow.com/questions/5951209/how-to-log-exception-and-message-with-placeholders-with-slf4j)