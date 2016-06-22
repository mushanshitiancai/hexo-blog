---
title: maven创建工程巨慢的解决方法
date: 2016-04-17 18:11:55
categories: [JAVA]
tags: java
---

使用`mvn archetype:generate`的时候一直很慢。会卡在`[INFO] Generating project in Batch mode`或者是`[INFO] Generating project in Interactive mode`上。让人瞬间没有写代码的欲望了😢

通过加上`-X`参数可以看到，这是因为archetype插件在新建工程时，会去获取线上的模板工程的目录文件地址是

    http://repo.maven.apache.org/maven2/archetype-catalog.xml

就是因为这个文件，拖慢了整个新建工程的步伐。

archetype插件有一个`archetypeCatalog`参数，这个参数指定从哪里获取`archetype-catalog.xml`文件，可选的取值有：

- `internal` 只使用内置的目录文件（只包含org.apache.maven.archetypes底下的模板工程）
- `local` 使用本地的目录文件（~/.m2/archetype-catalog.xml）
- `remote` 使用maven网站上的目录文件
- `file://path/to/archetype-catalog.xml` 指定本地的一个目录文件，如果文件叫`archetype-catalog.xml`指定目录就可以了
- `http://url/to/archetype-catalog.xml` 指定远程的一个目录文件，如果文件叫`archetype-catalog.xml`指定目录就可以了

默认的值是`remote,local`，也就是先显示官方网站上的，再显示本地的。所以我们可以有两种做法：

- 如果你觉得`org.apache.maven.archetypes`里的模板工程够用了，直接指定`-DarchetypeCatalog=internal`即可
- 如果你想要完整的模板工程，可以先下载http://repo.maven.apache.org/maven2/archetype-catalog.xml，然后把它放到`~/.m2`下，然后指定`-DarchetypeCatalog=local`即可

如果你使用的是IDEA，需要在设置中添加这个选项：

![](/img/java/idea-maven.png)

转自：[地址](http://my.oschina.net/u/225373/blog/468035)


PS. 附带一些可用的maven镜像：

``` 
<mirror>  
      <id>repo2</id>  
      <mirrorOf>central</mirrorOf>  
      <name>Human Readable Name for this Mirror.</name>  
      <url>http://repo2.maven.org/maven2/</url>  
    </mirror>  
<mirror>  
      <id>net-cn</id>  
      <mirrorOf>central</mirrorOf>  
      <name>Human Readable Name for this Mirror.</name>  
      <url>http://maven.net.cn/content/groups/public/</url>   
    </mirror>  
<mirror>  
      <id>ui</id>  
      <mirrorOf>central</mirrorOf>  
      <name>Human Readable Name for this Mirror.</name>  
     <url>http://uk.maven.org/maven2/</url>  
    </mirror>  
<mirror>  
      <id>ibiblio</id>  
      <mirrorOf>central</mirrorOf>  
      <name>Human Readable Name for this Mirror.</name>  
     <url>http://mirrors.ibiblio.org/pub/mirrors/maven2/</url>  
    </mirror>  
<mirror>  
      <id>jboss-public-repository-group</id>  
      <mirrorOf>central</mirrorOf>  
      <name>JBoss Public Repository Group</name>  
     <url>http://repository.jboss.org/nexus/content/groups/public</url>  
</mirror> 
```

## 参考资料
- [用maven骨架生成项目速度慢的问题 - 9leg](http://9leg.com/maven/2015/02/01/why-is-mvn-archetype-generate-so-low.html)
- [Maven Archetype Plugin – Generate project using an alternative catalog](https://maven.apache.org/archetype/maven-archetype-plugin/examples/generate-alternative-catalog.html)
- [如何使用Maven的archetype快速生成一个新项目 - 卜海清 - 博客园](http://www.cnblogs.com/buhaiqing/archive/2012/11/04/2754187.html)
- [idea maven mvn archetype:generate 速度缓慢问题 - iamyangjy的个人空间 - 开源中国社区](http://my.oschina.net/u/225373/blog/468035)
- [两个比较稳定的maven mirror - 刺猬的温驯 - 博客园](http://www.cnblogs.com/chenying99/archive/2012/06/23/2559218.html)