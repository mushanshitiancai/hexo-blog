---
title: IntelliJ IDEA中设置Tomcat服务器配置
date: 2017-09-07 10:08:05
categories: [Java]
tags: [java,idea,tomcat]
---

IDEA的Run/Debug Configuration设置面板中，没有办法设置Tomcat的具体配置，那我们用IDEA启动Tomcat的话，要如何配置Tomcat呢？

<!-- more -->

使用IDEA启动Tomcat的话，运行应用时，Server Tab中会输出相关的启动信息：

```
Z:\Server\apache-tomcat-7.0.55\bin\catalina.bat run
[2017-10-09 10:14:58,427] Artifact learn-spring:war exploded: Server is not connected. Deploy is not available.
Using CATALINA_BASE:   "C:\Users\Administrator\.IntelliJIdea2017.1\system\tomcat\Unnamed_learn-java_2"
Using CATALINA_HOME:   "Z:\Server\apache-tomcat-7.0.55"
Using CATALINA_TMPDIR: "Z:\Server\apache-tomcat-7.0.55\temp"
Using JRE_HOME:        "Z:\JDK"
Using CLASSPATH:       "Z:\Server\apache-tomcat-7.0.55\bin\bootstrap.jar;Z:\Server\apache-tomcat-7.0.55\bin\tomcat-juli.jar"
```

`CATALINA_HOME`是Tomcat的安装目录，根据你在IDEA中设置的Tomcat是内置还是外置，以及外置的路径的不同而不同。

`CATALINA_BASE`是Tomcat的工作目录。什么是工作目录呢。有时候你可能需要在一个机器上运行多个Tomcat实例，目的可能是因为各个的Tomcat的配置不一样等，一般来说，这需要你安装多个Tomcat，这给管理带来一定的麻烦。Tomcat支持多实例，每个实例共享同一个Tomcat运行程序，只是配置和运行其中的程序不一样。具体来说，Tomcat的目录结构为：

```
bin
lib
conf
logs
temp
webapps
work
```

各个实例需要定制的部分为：

```
conf
logs
webapps
work
```

`CATALINA_BASE`所指向的目录包含这些文件夹。

所有实例共享的部分为：

```
bin
lib
```

`CATALINA_HOME`所指向的目录包含这两个目录。

IDEA就是通过这种方式来运行Tomcat的，每个项目都生成一个Tomcat工作目录，做到互相不影响，所以我们定位到项目的工作目录，修改其`conf/server.xml`就行了。


另外说一个问题，就是打开IDEA生成的项目的工作目录会发现，只有conf,logs,work这三个目录，没有webapps这个目录，那IDEA吧应用部署到哪里去了呢？观察发现，其存在一个配置文件：conf/Catalina/localhost/ROOT.xml，内容为：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Context path="" docBase="D:\project\mushan\learn-java\learn-java\learn-spring\target\learn-spring" />
```

这个配置指定url path对应的根目录路径。一般我们会把应用部署到`/`下，这也是IDEA的默认配置，所以IDEA会生成`conf/Catalina/localhost/ROOT.xml`配置文件，指定根路径对应的目录为其target生成的项目。这个ROOT.xml还一般用于修改Tomcat默认的根路径对应的应用。

## 参考资料
[CATALINA_BASE与CATALINA_HOME的区别 - - ITeye博客](http://yuri-liuyu.iteye.com/blog/960964)