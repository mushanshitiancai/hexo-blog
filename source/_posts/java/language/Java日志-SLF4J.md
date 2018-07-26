---
title: Java日志-SLF4J
date: 2018-07-22 21:22:13
categories: [Java,掌握Java]
tags: [java]
toc: true
---

SLF4J全称The Simple Logging Facade for Java，Java简易日志门面，将接口抽象与实现隔离开，在不修改代码的情况下使用不同的日志实现。

<!-- more -->

SLF4J支持的日志实现有：

- log4j
- logback（推荐实现）
- java.util.logging
- simple（全部输出到System.err）
- Jakarta Commons Logging
- nop（忽略所有日志）

## 使用SLF4J

只要在项目中引入SLF4J的jar包就能开启SLF4J：

```xml
<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>slf4j-api</artifactId>
    <version>1.7.25</version>
</dependency>
```

然后写一个最简单的输出日志的程序：

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HelloWorld {      
    public static void main(String[] args) {    
        Logger logger = LoggerFactory.getLogger(HelloWorld.class);
        String name = mushan;    
        logger.info("Hello {}", mushan);  
    }
} 
```

程序运行会在控制台打印：

```java
SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".
SLF4J: Defaulting to no-operation (NOP) logger implementation
SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details.
```

因为slf4j在classpath中没有找到任何一个slf4j binding，所以会提示一个错误信息，并提示会使用NOP logger，这个logger的行为就是忽略所有输出。

## 关于参数

上面的例子，使用到了`{}`占位符，这是slf4j的参数占位符，效果与使用`+`进行字符串拼接是一样的，项目中也经常会看到使用`+`的例子，这是不好的，因为有性能问题。

比如这样的一个日志语句：

```java
logger.debug("Entry number: " + i + " is " + String.valueOf(entry[i]));
```

为了调用debug函数，需要执行这个字符串拼接语句，需要把`i`和`entry[i]`转为字符串，然后拼接。如果日志没有开启，或者日志级别高于debug，日志是不需要打印的，但是这个拼接消耗却是没有办法避免的。

所以日志框架后面想出了一个办法：

```java
if(logger.isDebugEnabled()) {
  logger.debug("Entry number: " + i + " is " + String.valueOf(entry[i]));
}
```

先使用`logger.isDebugEnabled()`方法检测对应的日志级别是否打开，打开了我才调用日志打印函数。但是这样做的问题是：1.麻烦，每次需要打印日志都要写一句检测判断 2.如果日志是开启了debug日志级别，但是日志本身是disable的话，依然有不必要的参数拼接消耗。

所有slf4j推荐的使用方式是：

```java
Object entry = new SomeObject();
logger.debug("The entry is {}.", entry);
```

日志实现在必要的时候才会替换日志中的`{}`占位符为具体的参数，所有不会有无意义的消耗。

按slf4j官网的说法，下面两种写法在日志被禁用的情况下，性能查了30倍（有点意外）：

```java
logger.debug("The new entry is "+entry+".");
logger.debug("The new entry is {}.", entry);
```

如果你需要在日志中输出`{}`本身，可以使用`\`进行转义：

```java
logger.debug("Set \\{} differs from {}", "3");
```

这样会输出：`Set {} differs from 3`。

## 绑定日志实现

之前提到了slf4j支持很多日志实现，slf4j包含了一些日志实现的桥接库，称为`SLF4J bindings`，官方提供的binding有：

- `slf4j-log4j12-1.8.0-beta2.jar`
  log4j1.2.x的binding，应该是使用最广的了。需要引入log4j。
Binding for log4j version 1.2, a widely used logging framework. You also need to place log4j.jar on your class path.
- `slf4j-jdk14-1.8.0-beta2.jar`
  JDK1.4提供的`java.util.logging`的binding
- `slf4j-nop-1.8.0-beta2.jar`
  NOP的binding，忽略所有日志
- `slf4j-simple-1.8.0-beta2.jar`
  简单日志实现，输出所有日志到System.err，只会输出大于等于INFO级别的日志。小程序可以用这个实现。
- `slf4j-jcl-1.8.0-beta2.jar`
  Jakarta Commons Logging日志库的binding，这个binding会代理所有的日志操作到JCL。JCL也是一个日志门面，但是目前已经被slf4j取代了。
- `logback-classic-1.0.13.jar` (requires logback-core-1.0.13.jar)
  这是slf4j的官方日志实现（其实log4j，slf4j，logback都是一家出品），logback就是按照slf4j的API直接实现的，所以不需要中间的binding。所以用这个官方实现，中间的损耗也是最小的。

切换日志实现，只要使用不同的binding jar包即可。不同于JCL，slf4j没有使用类加载器，而是在binding中硬绑定具体的实现。所以classpath中同时只能存在一个实现的binding。所以slf4j没有JCL可能的类加载器问题和内存损耗问题。

slf4j1.6之前，如果没有找到binding，slf4j会抛出`NoClassDefFoundError`异常，1.6之后，即使没有binding，slf4j也不会抛出异常，只是提示没有找到binding。所以对于库或者框架的作者来说，一定不要在项目中添加具体的slf4j binding，只要添加slf4j本身即可，让用户有机会选择具体的实现。

slf4j，slf4j binding，日志实现之间的关系见下图：

![](https://www.slf4j.org/images/concrete-bindings.png)


## SLF4J源码分析

slf4j是如何实现部署时绑定日志实现呢？我们来分析一下他的代码，以下分析基于slf4j 1.7.25。

顺便说一句，在网上看到很多分析slf4j的文章，得到的结论是使用类加载器来加载具体实现，这个是完全错误的。slf4j的官网已经明确说明slf4j不使用任何类加载器，这是他的一个优点，不会有类加载器冲突，不会有内存占用问题。

先看一下slf4j的整体类图：

![](/img/java/log/slf4j-logger.png)

我们获取Logger的方法是`LoggerFactory.getLogger(name)`，所以入口方法就是这个工厂方法：

```java
public static Logger getLogger(String name) {
    ILoggerFactory iLoggerFactory = getILoggerFactory();
    return iLoggerFactory.getLogger(name);
}
```

可以看出LoggerFactory不是真正的日志类工厂，真正的日志类工厂获取流程如下：

```java
// 使用一个变量表示当前的初始化状态，因为可能多线程同时初始化，所以该状态变量声明为volatile
static volatile int INITIALIZATION_STATE = UNINITIALIZED;

public static ILoggerFactory getILoggerFactory() {
    // 如果还未进行初始化，则进行初始化，这里使用了多线程常用的double-check技术
    if (INITIALIZATION_STATE == UNINITIALIZED) {
        synchronized (LoggerFactory.class) {
            if (INITIALIZATION_STATE == UNINITIALIZED) {
                INITIALIZATION_STATE = ONGOING_INITIALIZATION;
                // 初始化，绑定具体日志实现的逻辑在此
                performInitialization();
            }
        }
    }

    // 根据不同的初始化结果，返回不同的LoggerFactory
    switch (INITIALIZATION_STATE) {
    case SUCCESSFUL_INITIALIZATION:
        // 初始化成功，返回具体的日志实现提供的LoggerFactory
        return StaticLoggerBinder.getSingleton().getLoggerFactory();
    case NOP_FALLBACK_INITIALIZATION:
        // 初始化失败，返回NOPLogger
        return NOP_FALLBACK_FACTORY;
    case FAILED_INITIALIZATION:
        throw new IllegalStateException(UNSUCCESSFUL_INIT_MSG);
    case ONGOING_INITIALIZATION:
        // 防止初始化日志过程中出现递归初始化的问题
        // See also http://jira.qos.ch/browse/SLF4J-97
        return SUBST_FACTORY;
    }
    throw new IllegalStateException("Unreachable code");
}
```

我们进一步来看slf4j如何绑定日志实现：

```java
private final static void performInitialization() {
    // 绑定逻辑在此
    bind();

    // 绑定后的版本兼容性检查
    if (INITIALIZATION_STATE == SUCCESSFUL_INITIALIZATION) {
        versionSanityCheck();
    }
}

private final static void bind() {
    try {
        Set<URL> staticLoggerBinderPathSet = null;
        // 检测classpath是否存在多个slf4j binding，如果存在多个，则打印提示
        // 这里有一个优化，就是如果是安卓平台，就跳过检查，因为安卓打包后不会有重复的类
        if (!isAndroid()) {
            staticLoggerBinderPathSet = findPossibleStaticLoggerBinderPathSet();
            reportMultipleBindingAmbiguity(staticLoggerBinderPathSet);
        }

        // 这就是slf4j绑定具体日志实现的逻辑，就一句话！
        StaticLoggerBinder.getSingleton();

        INITIALIZATION_STATE = SUCCESSFUL_INITIALIZATION;

        // 如果classpath中存在多个slf4j binding，则在此打印出最终使用的binding
        reportActualBinding(staticLoggerBinderPathSet);
        fixSubstituteLoggers();
        replayEvents();
        // release all resources in SUBST_FACTORY
        SUBST_FACTORY.clear();
    } catch (NoClassDefFoundError ncde) {
        // 如果classpath不存在任何slf4j binding，则找不到StaticLoggerBinder类
        // 会抛出NoClassDefFoundError，这捕获改异常，如果没有找到binding，则使用NOPLogger
        String msg = ncde.getMessage();
        if (messageContainsOrgSlf4jImplStaticLoggerBinder(msg)) {
            INITIALIZATION_STATE = NOP_FALLBACK_INITIALIZATION;
            Util.report("Failed to load class \"org.slf4j.impl.StaticLoggerBinder\".");
            Util.report("Defaulting to no-operation (NOP) logger implementation");
            Util.report("See " + NO_STATICLOGGERBINDER_URL + " for further details.");
        } else {
            failedBinding(ncde);
            throw ncde;
        }
    } catch (java.lang.NoSuchMethodError nsme) {
        String msg = nsme.getMessage();
        if (msg != null && msg.contains("org.slf4j.impl.StaticLoggerBinder.getSingleton()")) {
            INITIALIZATION_STATE = FAILED_INITIALIZATION;
            Util.report("slf4j-api 1.6.x (or later) is incompatible with this binding.");
            Util.report("Your binding is version 1.5.5 or earlier.");
            Util.report("Upgrade your binding to version 1.6.x.");
        }
        throw nsme;
    } catch (Exception e) {
        failedBinding(e);
        throw new IllegalStateException("Unexpected initialization failure", e);
    }
}
```

最关键的一句话是最简单的一句话:

```java
StaticLoggerBinder.getSingleton();
```

这里slf4j要求所有的binding必须实现一个`org.slf4j.impl.StaticLoggerBinder`类，slf4j就用最普通的方式实例化这个类。存在三种情况：

1. classpath中不存在这个类。这种情况是没有添加任何binding的情况，这种情况下这句话抛出`NoClassDefFoundError`异常，slf4j捕获异常，返回NOPLoggerFactory。
2. classpath存在这个类，且只有一个。slf4j实例化这个类，并调用`StaticLoggerBinder.getSingleton().getLoggerFactory()`方法得到具体的实现的LoggerFactory。
3. classpath存在多个同样全限定名的类。JVM是允许这种情况的，这种情况下，会使用更靠前的那个类，因为JVM是从前往后搜索类的。slf4j在这种情况下，为了提醒用户，会答应出classpath存在的类，与最终使用的binding。

所以，通过这种方式，slf4j不需要自定义类加载器就能绑定不同的日志实现。优点是实现简单，性能高，兼容性高，缺点是无法在运行时切换日志实现，不过这个基本上也用不到。

还有一个问题，slf4j-api项目本身，存在`org.slf4j.impl.StaticLoggerBinder`这个类吗？不存在的话，编译是没法通过的，如果存在这个类，可能会覆盖binding中的类，这个问题如何解决？

在slf4j-api项目的pom中发现了这么一个配置：

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-antrun-plugin</artifactId>
  <executions>
    <execution>
      <phase>process-classes</phase>
      <goals>
        <goal>run</goal>
      </goals>
    </execution>
  </executions>
  <configuration>
    <tasks>
      <echo>Removing slf4j-api's dummy StaticLoggerBinder and StaticMarkerBinder</echo>
      <delete dir="target/classes/org/slf4j/impl"/>
    </tasks>
  </configuration>
</plugin>
```

使用maven的ant插件，在打包前删除了`target/classes/org/slf4j/impl`下的class文件，这样发布出去的slf4j就不存在这个类了，真是太机智了。

## 总结

- slf4j是Java简易日志门面，可以在不修改代码的情况下，在部署时使用不同的日志实现
- slf4j支持参数化消息，在日志关闭的情况下，减少不必要的字符串拼接和类型转换，提高性能
- slf4j使用静态绑定的方式绑定具体的日志binding，依赖binding实现的`org.slf4j.impl.StaticLoggerBinder`类，没有使用自定义类加载器
- slf4j允许classpath存在多个slf4j binding，但是只会使用其中一个

## 参考资料
- [SLF4J Manual](https://www.slf4j.org/manual.html)
- [SLF4J FAQ](https://www.slf4j.org/faq.html#logging_performance)