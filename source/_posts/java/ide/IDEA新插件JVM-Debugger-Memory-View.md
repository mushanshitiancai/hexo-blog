---
title: IDEA新插件JVM Debugger Memory View
date: 2016-11-28 09:48:01
categories: [Java]
tags: [java,idea]
---

[JVM Debugger Memory View for IntelliJ IDEA | IntelliJ IDEA Blog](https://blog.jetbrains.com/idea/2016/08/jvm-debugger-memory-view-for-intellij-idea/)

JVM Debugger Memory View是JetBrain在八月份推出的一个插件，这次在JetBrain的北京开发者日上，看到了布道师演示时说道了这个插件，可以用来查看目前堆中类的个数的情况，对调试有一定的帮助。

在调试时，View → Tool Windows → Memory View打开Memory View窗口。

![](https://d3nmt5vlzunoa1.cloudfront.net/idea/files/2016/08/memory_analyzer_2.png)

你在调试的过程中，右边的diff会显示这次跳转类的变化，而且你可以trace这些变化的类。算计对应的类，就可以在视图中查看所有实例

![](https://d3nmt5vlzunoa1.cloudfront.net/idea/files/2016/08/memory_analyzer_1.png)