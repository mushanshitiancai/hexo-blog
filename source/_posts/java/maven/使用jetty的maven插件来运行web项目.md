---
title: 使用jetty的maven插件来运行web项目
date: 2016-07-30 11:03:07
categories: [Java]
tags: [java,maven]
---

一般运行web项目都是用IDEA来配置部署到tomcat来运行的。后来发现可以在maven项目的pom中配置jetty的插件来运行，一句命令就可以运行项目，非常方便，而且与IDE无关。

## 添加Jetty插件
在工程pom文件中添加如下代码：

```
<build>
    <plugins>
        <plugin>
            <groupId>org.eclipse.jetty</groupId>
            <artifactId>jetty-maven-plugin</artifactId>
            <version>9.3.11.v20160721</version>
        </plugin>
    </plugins>
</build>
```

然后执行`mvn jetty:run`，就可以访问http://localhost:8080/了。

## 配置Jetty容器
### 修改端口

```
<configuration>
  <httpConnector>
    <port>8081</port>
  </httpConnector>
</configuration>
```


## 参考资料
- [Configuring the Jetty Maven Plugin](http://www.eclipse.org/jetty/documentation/9.4.x/jetty-maven-plugin.html)
- [maven jetty 插件使用 - fanlychie - BlogJava](http://www.blogjava.net/fancydeepin/archive/2015/06/23/maven-jetty-plugin.html)