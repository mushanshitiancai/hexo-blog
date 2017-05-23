---
title: Servlet3学习笔记-注解和可拔插特性
date: 2017-05-23 16:18:59
categories: [Java]
tags: [java,servlet]
---

Servlet3是带来了几个牛逼的新特性：

- 异步处理支持
- 新增的注解支持
- 可拔插支持

可拔插支持在平时写码的过程中可能没有接触到，但是对于框架设计者来说，是非常重要的特性，比如Spring就利用了Servlet3的可拔插特性，实现无需xml配置即可启动Spring上下文。今天我们就来说说Servlet3中的注解和可拔插设计。

<!-- more -->

## 新的注解

Servlet3中添加了几个注解，实现了无需`web.xml`配置即可声明Servlet/过滤器/监听器。新加的主要注解有：

- @WebServlet
- @WebFilter
- @WebListener
- @WebListener
- @MultipartConfig

使用这些注解，可以实现本来需要在web.xml中使用配置来实现的声明功能。而且因为容器会扫描所有依赖的jar的class，所以那些在第三方库使用注解声明的Servlet/过滤器/监听器在应用启动的时候也会被识别！这就实现了可拔插特性。

但是注解也有其缺点，就是无法指定顺序，如果对于顺序有要求，就需要使用部署描述符了。

## web-fragment.xml

`web.xml`大家一定都知道了，但是`web-fragment.xml`可能还没见过。这是Servlet3引入的称之为“Web部署描述符片段”的文件，这个文件必须放在jar文件中的`META-INF`目录下。对，jar文件中的，所以这个文件是给第三方库来使用的，也就是说不单单应用本身可以定义web应用的属性，现在第三方库也可以定义了。`web-fragment.xml`中可以包含一切`web.xml`中定义的内容。

比如一个库，他实现了一些公用的Servlet，以往，如果需要引入，还需要使用者手动在`web.xml`中添加这些Servlet。而现在，库的作者可以在库的代码中定义`web-fragment.xml`，在其中添加这个库需要定义的Servlet，过滤器，监听器等。使用者只要把jar包放到WEB-INF/lib下即可生效。这就是Servlet的可拔插。

## web-fragment.xml顺序与冲突解决

Servlet规范制定者仔细地考虑了这个问题，指定了一套完整的解决策略，具体的可以参考规范。

## ServletContainerInitializer接口

除了注解+web-fragment.xml这两个实现可拔插的手段，Servlet3还提供了一个最最最自由的实现可拔插的方式，就是代码方式。Servlet3提供了`ServletContainerInitializer`这个新接口，这个接口只有一个`onStartup`方法，通过以下步骤，容器在启动时会调用这个方法：

1. 在jar包的`META-INF/services`中新建一个`javax.servlet.ServletContainerInitializer`文件
2. 在新建的文件中写入你实现的`ServletContainerInitializer`实现类的全限定名
3. 在你的应用中引入该jar文件

这样在启动应用时，在Listener运行前，容器就会运行每个jar中符合条件的实现类的`onStartup`方法。看例子会更清楚：

```java
public class MyServletContainerInitializer implements ServletContainerInitializer{

    public void onStartup(Set<Class<?>> c, ServletContext ctx) throws ServletException {
        System.out.println("onStartup");
    }
}
```

然后定义`META-INF/services/javax.servlet.ServletContainerInitializer`文件，假设`MyServletContainerInitializer`在`mushan`这个package下：

```
mushan.MyServletContainerInitializer
```

然后打包这个jar作为应用的依赖，启动应用就能看到`onStartup`方法被调用了。其第一个参数为`null`。

Servlet3还提供了一个配套的注解`@HandlesTypes`，其中指定的接口的子类的Class实例都会被作为`onStartup`的第一个参数。如果，不指定，则第一个参数为`null`。这个主要是用来过滤需要处理的类的。

Spring3.1中就实现了这个接口，实现类是`SpringServletContainerInitializer`，其中调用了`WebApplicationInitializer`，这也就是Spring无`web.xml`配置的原理。

## 参考资料
- [Servlet 3.0 新特性详解](https://www.ibm.com/developerworks/cn/java/j-lo-servlet30/)