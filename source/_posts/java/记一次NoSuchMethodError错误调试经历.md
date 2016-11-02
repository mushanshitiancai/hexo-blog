---
title: 记一次NoSuchMethodError错误调试经历
date: 2016-11-02 14:18:15
categories: [Java,调试]
tags: java
---

故事的开始是发现一个函数明显没有走完，但是包含了所有逻辑的try块也没有捕获到错误，程序到底执行到哪里去了？在测试环境调试，一路设置断点，发现在一个数据上，断点怎么就是不执行了，线程跳出，catch块也有执行。而关键的语句只是一句用new构造的语句，为什么会不执行了呢？

背景故事可能没有说清楚，但是我想说的是，就是以为被“catch块没有打印出日志”这个表现所误导，所以我们认为“程序灵异跳出了”，导致我在很长一段时间内，一直重复调试，但是就一直没有关注过控制台输出。。。知道有人提到，我一看：

```
java.lang.BootstrapMethodError: java.lang.NoSuchMethodError: com.protocol.FRequest.<init>(Lcom/protocol/FMessageType;)V
```

我擦，原来一直有错误输出的，为什么catch块没有执行？？？看看catch怎么写的：

```
catch (Exception e) {
    ...
}
```

突然，以前学的Java异常体系知识点在脑内闪过

![](http://img.my.csdn.net/uploads/201211/27/1354020417_5176.jpg)

Exception和Error都是Throwable的子类，`java.lang.NoSuchMethodError`是Error的子类，所以如果`catch (Exception e)`只会捕获Exception以及他的子类，而不会捕获Error和Error的子类，所以错误就会输出到控制台，线上程序没有控制台，所以就查不到这个错误日志！

所以如果你想要捕获所有的异常，一定要这么写：

```
catch (Throwable e) {
    ...
}
```

既然看到了异常，那么问题就从灵异级别降到了普通级别，这就好解决了。

`java.lang.NoSuchMethodError`一看就是因为依赖的关系，导致运行时没有找到对应的方法导致的。

对于依赖这个可怕的问题漩涡，我倾向的解决方法是先不要在POM文件中纠结，而是直接去看打包后的war包或者jar包中的lib文件夹，查看程序在运行时真正用到的jar包是否正确。

首先可以使用unzip来解压war/jar包，然后进入lib目录，这里就可以查看这些依赖的版本了，因为版本都是写在文件名上的，如果版本没有问题，则可以解决出问题的类所在的jar包，然后使用jdk自带的反编译工具反编译类：

```
$ javap -s 

警告: 二进制文件FRequest包含com.protocol.FRequest
Compiled from "FRequest.java"
public class com.protocol.FRequest extends com.protocol.AbstractFMessage {
  public com.protocol.FRequest(com.protocol.FMessageType);
    descriptor: (Lcom/facishare/fcp/protocol/FMessageType;)V
}
```

这个方法具体还可以参考[java.lang.NoSuchMethodError 调试和解决方法][java.lang.NoSuchMethodError 调试和解决方法]。

但是我发现这里发现函数签名是一致的，那为啥还找不到这个方法呢？所以想看看运行这个函数到底是如何的，可以这么做：在IDEA中调试，进入断点后，使用调试工具Evaluate Expression，这个调试工具非常强大，可以在调试的时候执行Java表达式，大家一定要善用。

执行这样的表达式：

```
Class.forName("com.protocol.FRequest").getConstructors()
```

这就可以获得这个函数所有的构造函数了，看了函数签名，发现的确不一致！说明运行时载入的并不是我们查看的那个类。

最后搜索了一下工程，发现在两个依赖中都定义了这个类，包一样，但是参数列表不一样，估计是另外一个后载入，所以最终使用的不是我所预期的那个类，在pom中排除即可。

## 参考资料
- [java.lang.NoSuchMethodError 调试和解决方法][java.lang.NoSuchMethodError 调试和解决方法]

[java.lang.NoSuchMethodError 调试和解决方法]: http://timen-zbt.iteye.com/blog/1871152
