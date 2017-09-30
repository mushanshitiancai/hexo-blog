---
title: Google依赖注入框架Guice学习笔记
date: 2016-09-05 11:46:20
categories: [Java]
tags: [java]
---

Guice是Google在2006年推出的一个轻量级依赖注入框架。相比于诞生于2004年的Spring，晚了两年。那个时候Spring已经声名鹊起，基本上成为业界标准了。但是，因为Spring诞生的时候，超级经典的Java5还没有出来（2004年末），所以Spring一开始只能在xml中配置Bean。而Guice一开始就基于Java5设计，使用了其注解的特性，所Guice没有xml配置文件，Bean的依赖关系是在代码中直接配置的。这也是Guice比Spring启动快的原因。

虽然Spring在后续的版本中加入了对注解注入的支持，但是直到现在，大部分的项目依然使用xml配置。这是基因问题，就像很多大公司会在新领域上被小公司打败一样。

## Hello World
添加依赖：

```
<dependency>
  <groupId>com.google.inject</groupId>
  <artifactId>guice</artifactId>
  <version>4.1.0</version>
</dependency>
```

编写武器接口：

```
public interface Weapon {
    void attack();
}
```

编写一个武器的实例，剑：

```
public class Sword implements Weapon {

    public void attack() {
        System.out.println("sword attack!");
    }
}
```

编写使用武器的士兵：

```
public class Soldier {

    @Inject
    private Weapon weapon;

    public void attack(){
        weapon.attack();
    }
}
```

士兵里并没有指定具体他使用的武器时哪种，而是面向接口编程，根据外部注入的具体武器，来到达不同的攻击效果。这里的weapon数学需要注入，可以直接在其属性上使用Inject注解。Guice会对使用Inject注解的属性进行注入。

这里需要注意一点，在2009年末发布的Java EE 6中，包含了两个标准：

- JSR 299: Contexts and Dependency Injection for the JavaTM EE platform
- JSR 330: Dependency Injection for Java

都是对于依赖注入的规范。其中299针对JavaEE，而330则是Java通用的。330定义了一些注解，作为Java平台依赖注入的标准。改规范退出后，Spring和Guice都已经兼容该规范，所以在Spring和Guice中都可以使用JSR-330的注解进行依赖注入。

所以这里的`@Inject`既可以使用`com.google.inject.Inject`，也可以使用`javax.inject.Inject`。

然后需要定义依赖的配置，Guice的依赖配置是使用代码进行配置的，而不是配置文件。依赖配置类需要继承AbstractModule，实现configure方法：

```
public class DemoModule extends AbstractModule {

    protected void configure() {
        bind(Weapon.class).to(Sword.class);
    }
}
```

这里定义了如果发现Weapon接口，就使用Sword这个类来注入。然后我们编写入口函数：

```
public class Main {
    public static void main(String[] args) {
        Injector injector = Guice.createInjector(new DemoModule());
        Soldier soldier = injector.getInstance(Soldier.class);
        soldier.attack();
    }
}
```

通过`injector.getInstance`获取实例，并调用成功。


## 参考资料
- [Motivation · google/guice Wiki](https://github.com/google/guice/wiki/Motivation)
- [Java EE version history - Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Java_EE_version_history)
- [Java version history - Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Java_version_history)
- [Java 依赖注入标准（JSR-330）简介 - 简约设计の艺术 - 博客频道 - CSDN.NET](http://blog.csdn.net/DL88250/article/details/4838803)

