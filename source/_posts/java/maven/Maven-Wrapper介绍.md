---
title: Maven Wrapper介绍
date: 2017-10-18 09:33:16
categories: [Java]
tags: [java,maven]
---

使用https://start.spring.io/生成Spring Boot项目时，发现其中包含几个奇怪的文件：

```
.
├── .mvn
│   └── wrapper
│       ├── maven-wrapper.jar
│       └── maven-wrapper.properties
├── mvnw
└── mvnw.cmd
```

这些文件是干嘛的呢？其实是Maven Wrapper。要说得先说说什么是Gradle Wrapper。

一般我们使用Gradle就是在电脑上安装Gradle，然后在命令行中使用，这个没什么问题，但是如果要将项目打包给没有安装Gradle的人运行就有些麻烦，这倒是小事，更麻烦的是组里的人统一Gradle版本，如果大家都自己安装Gradle，可能会因为版本不一致导致一些小问题。考虑到这一点，Gradle提供了Gradle Wrapper功能，能够在项目中携带一个Gradle代理，使用者只要使用这个Gradle代理就行，代理执行命令时，会查找本地系统是否存在指定版本的Gradle，如果存在，则代理命令到Gradle，如果不存在，会下载指定版本的Gradle，再进行处理。所以使用者就不用担心怎么安装，安装什么版本的Gradle了。Gradle Wrapper对应到的文件如下：

```
Project-name/  
  gradlew  
  gradlew.bat  
  gradle/wrapper/  
    gradle-wrapper.jar  
    gradle-wrapper.properties  
```

而Maven官网没有提供Wrapper功能，不过第三方提供了一个Wrapper：[takari/maven-wrapper: The easiest way to integrate Maven into your project!](https://github.com/takari/maven-wrapper)

使用方式也Gradle Wrapper基本是一样的。安装是通过执行一个插件做到的：

```
mvn -N io.takari:maven:wrapper
```

执行命令后就会在项目目录下生成一个Maven Wrapper，目录结构和文章开头提出的一样。然后所有命令就可以通过`mvnw`来执行了：

```
$ ./mvnw clean install
```

`mvnw`在执行时，如果发现本地没有安装对应版本的maven，就会根据`.mvn/wrapper/maven-wrapper.properties`中指定的url下载指定版本的Maven，然后代理调用真实的mvn来执行命令。

## 参考资料
- [maven - What is the purpose of mvnw and mvnw.cmd files? - Stack Overflow](https://stackoverflow.com/questions/38723833/what-is-the-purpose-of-mvnw-and-mvnw-cmd-files)
- [gradle wrapper的使用 - SteveJobson - CSDN博客](http://blog.csdn.net/stevejobson/article/details/53448071)
- [takari/maven-wrapper: The easiest way to integrate Maven into your project!](https://github.com/takari/maven-wrapper)