---
title: Intellj IDEA中maven项目的子module的依赖无法被识别
date: 2016-04-26 11:35:29
tags: java
---

昨天又遇到一个烦心事。经过是这样的：IDEA中新建maven工程，作为父级项目和聚合项目，然后建立一个webapp的module，这个module才是写代码的地方。但是我在module中的POM写的依赖，IDEA根本就没有添加到项目中，导致代码无法使用依赖中的类。

这难道是因为IDEA对maven的module支持不完善？

<!-- more -->

不能啊，maven出来这么久了，这种明显的问题应该不会有了吧。各种尝试无果，重新新建了一个项目，走一遍同样的流程，竟然可以了。。。。然后详细对比两者，发现了一个坑点：

![](/img/java/idea-ignore-maven-module.png)

( ⊙ o ⊙ )！

我是在什么时候ignore了这个module项目啊。。。。。

ignore了maven项目，idea自然就不会去处理他的POM了。
