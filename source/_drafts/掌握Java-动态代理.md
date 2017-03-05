---
title: 掌握Java-动态代理
date: 2017-01-06 10:04:02
categories: [Java,掌握Java]
tags: java
---

动态代理是AOP的关键技术。JDK自带了动态代理技术，即java.lang.reflect.Proxy。

我们需要代理是因为我们想要在现有的业务对象方法的执行前后做一些统一操作。我觉得“统一”是使用动态代理的前提，因为如果不是统一操作的话，使用动态代理的意义就不大了，而是应该手动继承或者是包装。

JDK的动态代理是基于接口的。也就是说不能直接代理一个类。这是因为JDK的生成的代理类是事先

JDK中使用动态代理还是很简单的，有以下几个步骤：

1. 定义需要代理的接口
2. 实现业务类，该业务类继承代理接口
3. 继承InvocationHandler接口，实现接口调用代理类
4. 使用Proxy.newProxyInstance()生成代理类
5. 把代理类强制转换为代理接口，调用

我们按这个步骤来写个例子吧：

```
// 1. 定义需要代理的接口
public interface Human {
    String say();
}

// 2. 实现业务类，该业务类继承代理接口
public class Man implements Human {
    @Override
    public String say() {
        return "hello";
    }
}

// 3. 继承InvocationHandler接口，实现接口调用代理类
public class InvocationHandlerImpl implements InvocationHandler {
    
    Man man;

    public InvocationHandlerImpl(Man man) {
        this.man = man;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        System.out.println("before invoke arg=" + Arrays.toString(args));
        Object invoke = method.invoke(man, args);
        System.out.println("after invoke ret=" + invoke);
        return invoke;
    }
}

// 4. 使用Proxy.newProxyInstance()生成代理类
Human man = new Man();
Object o = Proxy.newProxyInstance(man.getClass().getClassLoader(), man.getClass().getInterfaces(), new InvocationHandlerImpl((Man)man));

// 5. 把代理类强制转换为代理接口，调用
System.out.println(((Human)o).say());
```

输出：

```
before invoke arg=null
after invoke ret=hello
hello
```

我们的例子里业务类只实现了一个接口。其实也可以实现多个接口，生成的代理类代理什么接口我们是可以指定的。如果指定`man.getClass().getInterfaces()`，表示代理类会实现业务类上所有的接口。那么在使用的时候可以把代理类强转为对应的接口然后再进行使用。

## 原理

jdk的部分源码默认是没有提供的，所以我们需要手动下载Java8源码[OpenJDK™ Source Releases](http://download.java.net/openjdk/jdk8/)。解压后在IDEA中添加源码。

![](/img/java-add-java8-src.png)

然后就能开心的分析啦。


## 参考资料
- [Java动态代理机制详解（JDK 和CGLIB，Javassist，ASM） - 我的程序人生 - 博客频道 - CSDN.NET](http://blog.csdn.net/luanlouis/article/details/24589193)