---
title: Kotlin学习笔记
date: 2016-12-19 14:46:40
categories: [Java]
tags: [java,kotlin]
---

目前JVM上的各式语言中，Kotlin算是比较温和的一个，不像Scala那样激进，感觉就是Java+语法糖，所以可以做到和Java完美交互，同时学习门槛低，所以打算学习学习，并在工作中引入。

<!-- more -->

- package名字可以和文件的路径不匹配（为什么需要这么设计呢？我觉得匹配会更加清晰啊）
- kotlin中的类型写在变量后面
- kotlin中可变变量使用var声明，不可变变量使用val声明
- kotlin的Unit表示无意义的值
- kotlin的块注释是可以嵌套的，而Java不行
- kotlin的字符串支持使用`${}`来插入变量
- kotlin中的if语句是表达式，Java中支持语句
- kotlin中的变量，要么是不能为null，要么是Optional类型，通过在变量后面加个`?`表示。如果在使用Optional类型前没有进行判空，编译无法通过
- kotlin使用`is`来判断一个实例是否是一个类的实例，而且在判断成功后无需再强制转换
- kotlin使用`for..in`进行遍历
- kotlin的when和Java的switch类似，但是更加强大，是模式匹配
- kotlin使用`if (x in 1..y-1)`和`if (x !in 1..y-1)`来判断是否在区间内
