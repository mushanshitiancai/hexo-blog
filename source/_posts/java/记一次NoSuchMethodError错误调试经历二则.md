---
title: 记一次NoSuchMethodError错误调试经历二则
date: 2017-09-05 17:58:19
categories: [Java,调试]
tags: java
---

又一次遇到`java.lang.NoSuchMethodError`异常。上次的记录看这里：[记一次NoSuchMethodError错误调试经历](http://mushanshitiancai.github.io/2016/11/02/java/%E8%AE%B0%E4%B8%80%E6%AC%A1NoSuchMethodError%E9%94%99%E8%AF%AF%E8%B0%83%E8%AF%95%E7%BB%8F%E5%8E%86/)


这次是发布到线上后，必现`java.lang.NoSuchMethodError`异常，对应的方法是一个jar依赖里的。这个找不到的方法正是这个依赖这次的更新内容。难道线上的依赖没有更新为最新的本本？不可能啊，因为发布是打包为war后交给专门的运维进行上线的。依赖都是打包的war中的，不应该出现遗漏的情况。

而且使用javap命令查看了war包中对应的class文件（方法参考上一篇文章），的确是有这个方法的。同时因为没有权限直接操作线上的机器，导致无法查看线上的class的情况。

不能实操调试是最麻烦的，只能通过推理。因为依赖是打包到war中，而发布的时候也是用的同一个war，所以可以排除代码的问题。和对应的运维沟通：

问：你是如何发布war包对应的应用的？
答：解压覆盖

答案已经出来了，运维解压war包，并覆盖到目录应用，这回导致原来的没有被覆盖的老文件依然存在，于是就存在了多个版本的依赖，就会出现经典的“同一个类存在多份”的问题。

解决方法就是让运维删除在重新部署应用。