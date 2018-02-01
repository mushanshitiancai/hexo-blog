---
title: NullPointerException异常堆栈消失问题
date: 2018-01-30 17:28:16
categories: [Java]
tags: [java]
---

程序中抛出了大量的NullPointerException，但是奇怪的是没有堆栈信息，明明是堆栈打印到日志中的。

<!-- more -->

后来发现在大量的NullPointerException日志中，有小部分是有堆栈信息的，大部分没有。原来是Hotspot JVM在1.5时添加了一项优化`OmitStackTraceInFastThrow`。如果同一个异常被抛出很多次，则这个方法会被重新编译，重新编译后，这个方法会使用更快的抛出异常的方式，也就是一个预先分配好的不带堆栈信息的异常。所以在函数被JIT编译前，能看到堆栈信息，编译后，就没有堆栈信息了。

下面的代码可以模拟这种情况：

```java
public static void main(String[] args) {
    for (int i = 0; i < Integer.MAX_VALUE; i++) {
        try {
            work();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

private static void work(){
    String a = null;
    a.length();
}
```

一开始会抛出正常的带堆栈信息的异常：

```
java.lang.NullPointerException
	at fastthrow.Main.work(Main.java:22)
	at fastthrow.Main.main(Main.java:13)
```

一段时间后就没有堆栈信息了：

```
java.lang.NullPointerException
```

这个优化可以通过参数`-XX:-OmitStackTraceInFastThrow`关闭，这样就不会丢失堆栈了。

还有一个问题是什么异常会触发这个优化，所查资料没看到具体定义。大家举的例子都是NullPointerException。

我试着直接`throw new NullPointerException()`是不会触发优化的，throw自定义异常也不会。

> “The compiler in the server VM now provides correct stack backtraces for all “cold” built-in exceptions. For performance purposes, when such an exception is thrown a few times, the method may be recompiled. After recompilation, the compiler may choose a faster tactic using preallocated exceptions that do not provide a stack trace. To disable completely the use of preallocated exceptions, use this new flag: -XX:-OmitStackTraceInFastThrow.” http://java.sun.com/j2se/1.5.0/relnotes.html

从这段官方的原话中可以看出是针对`“cold” built-in exceptions`，但是具体什么是`“cold” built-in exceptions`还是不得而知。

## 参考资料
- [[译]生产环境中异常堆栈丢失的解决方案 | 戎码一生](http://rongmayisheng.com/post/%e8%af%91%e7%94%9f%e4%ba%a7%e7%8e%af%e5%a2%83%e4%b8%ad%e5%bc%82%e5%b8%b8%e5%a0%86%e6%a0%88%e4%b8%a2%e5%a4%b1%e7%9a%84%e8%a7%a3%e5%86%b3%e6%96%b9%e6%a1%88)
- [JVM参数分享 OmitStackTraceInFastThrow - 简书](https://www.jianshu.com/p/e87d166380eb)
- [JVM 看不到某些异常的stacktrace问题 - CSDN博客](http://blog.csdn.net/alivetime/article/details/6166252)
- [强制要求JVM始终抛出含堆栈的异常](http://jadyer.cn/2012/11/22/jvm-omit-stacktrace-in-fast-throw/)
- [Hotspot caused exceptions to lose their stack traces in production – and the fix at JAW Speak](http://jawspeak.com/2010/05/26/hotspot-caused-exceptions-to-lose-their-stack-traces-in-production-and-the-fix/)