---
title: 在IDE中运行调试Tomcat
date: 2016-05-27 17:51:00
tags: java
---

Tomcat是最流行的Java Web应用服务器，其源码值得研究。

研究源码的第一步是把它跑起来。Tomcat是一个老项目，其使用的构建工具是Ant，想要构建Tomcat，运行ant命令就可以了。但是阅读源码最后是在IDE中进行，因为可以调试，所以还的花点功夫把代码导入到IDE中。这里我使用eclispe。

网上有不少文章讲如何在IDE中运行tomcat的，有新建工程拷贝jar的，有使用maven的，我试了都不好使，看了tomcat的官网，在[Apache Tomcat 8 (8.0.35) - Building Tomcat](http://tomcat.apache.org/tomcat-8.0-doc/building.html)中看到了"Building with Eclipse"，官方编写了一个ant任务，可以生成eclispe工程，在eclispe中导入即可。

## 步骤
先下载tomcat的源码，地址：[Apache Tomcat® - Apache Tomcat 8 Software Downloads](http://tomcat.apache.org/download-80.cgi)，我下载的是8.0.35的源码包。

下载解压，运行`ant ide-eclipse`。运行的过程会下载jar包，这个过程是需要翻墙的。。可以在build配置文件中指定代理。

源码目录下有一个build.properties.default文件，复制一份，重命名为build.properties，就可以在其中修改配置了，比如加上代理：

```
# ----- Proxy setup -----
proxy.host=proxy.domain
proxy.port=7777
proxy.use=on
```

然后在eclispe中导入工程。导入工程后，需要在设置的Java->Build Path->Classpath Variables中设置两个变量：

- TOMCAT_LIBS_BASE build.properties文件中base.path值，默认是用户家目录下的tomcat-build-libs文件夹
- ANT_HOME ant的根目录

然后就可以运行tomcat啦，ant生成的eclispe工程里有两个运行配置`start-tomcat`和`stop-tomcat`，直接使用即可。

不过我在启动的时候遇到了问题：

```
五月 28, 2016 8:36:59 下午 org.apache.catalina.startup.CatalinaProperties loadProperties
警告: Failed to load catalina.properties
五月 28, 2016 8:36:59 下午 org.apache.catalina.startup.Catalina load
警告: Unable to load server configuration from [/Users/mazhibin/project/java/opensource/apache-tomcat-8.0.35-src/output/build/conf/server.xml]
五月 28, 2016 8:36:59 下午 org.apache.catalina.startup.Catalina load
警告: Unable to load server configuration from [/Users/mazhibin/project/java/opensource/apache-tomcat-8.0.35-src/output/build/conf/server.xml]
五月 28, 2016 8:36:59 下午 org.apache.catalina.startup.Catalina start
严重: Cannot start server. Server instance is not configured.
```

在`start-tomcat`和`stop-tomcat`配置中，指定了VM选项：

    -Dcatalina.home=${project_loc:/tomcat-8.0.x/java/org/apache/catalina/startup/Bootstrap.java}/output/build

而在这个目录下是没有conf文件夹的，倒是在源码根目录下有conf目录，删除这个参数就没问题了。

## 参考资料
- [Apache Tomcat 8 (8.0.35) - Building Tomcat](http://tomcat.apache.org/tomcat-8.0-doc/building.html)
- [怎样调试Tomcat源码](https://mp.weixin.qq.com/s?__biz=MzI3MTEwODc5Ng==&mid=402994558&idx=1&sn=3b87afca562a31df396b7743a20e38f0&scene=1&srcid=0526LOh92CzrfzlMtHvByMck&key=f5c31ae61525f82e828062ac33fe5d74735e3a227a458204c4d587b3bd79690e980ef7cde7f233f7c7cbb0c6cbc1365d&ascene=0&uin=NzQwMTA4NTgw&devicetype=iMac+MacBookPro12%2C1+OSX+OSX+10.11.1+build(15B42)&version=11020201&pass_ticket=CHARmusHGSg2t%2Fzpr4VHhXer5lLgeEMCcsdzNuCRC%2FyAhHBWP3tUM7y%2BzHfPF9%2BQ)
- [在IntelliJ IDEA 和 Eclipse运行tomcat 7源代码（Tomcat源代码阅读系列之一） - 推酷](http://www.tuicool.com/articles/Rz6Fnyf)