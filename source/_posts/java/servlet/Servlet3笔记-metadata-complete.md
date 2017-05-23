---
title: Servlet3笔记-metadata-complete
date: 2017-05-23 16:50:42
categories: [Java]
tags: [java,servlet]
---

`metadata-complete`是一个在Servlet2.5就存在的一个属性。Servlet2.5搭了Java5的顺风车，支持注解，这就涉及到需要扫描类的问题了。在类的数目比较多的情况下，扫描类可能会带来启动时间的延长。所以为了可以控制这个过程，`web.xml`的`web-app`标签添加了一个属性：`metadata-complete`，如果为true，表示`web.xml`中包含了全部的配置信息了，不需要再扫描代码。而如果为false，则表示`web.xml`中没有包含全部信息，还需要扫描类。

在Servlet3中，除了添加了更多更实用的注解外，还添加了`web-fragment.xml`这个位于jar包中的配置文件。所以`web.xml`中`metadata-complete`的涵义得到了延伸：

如果为true：

- 不扫描应用的类的注解
- 不读取jar文件中的`web-fragment.xml`

如果为false：

- 扫描应用的类的注解
- 读取jar文件中的`web-fragment.xml`

`web-fragment.xml`中虽然也可以设置这个属性，但是**无效**。