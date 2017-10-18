---
title: Spring Boot CLI使用
date: 2017-10-18 19:40:59
categories: [Java,Spring]
tags: [java,spring]
---

Spring Boot CLI是Spring Boot项目提供的一个用于快速运行Spring Boot应用的命令行工具，通过结合Groovy，可以实现一个文件的WEB应用，用于快速实验原型是最好不过的了。

<!--more-->

## 安装
手动安装：https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#getting-started-installing-the-cli

下载spring-boot-cli-1.5.8.RELEASE-bin.zip，解压，然后把spring-1.5.8.RELEASE\bin的路径加入PATH环境变量。

## 一个文件的web应用
一般Java想要启动一个web应用需要很多样板代码与配置，一个基于Spring的web应用就更加可怕了，如果没有IDE的帮助，新建一个估计得查半天资料。而使用Spring Boot CLI我们只需要一个文件！

新建文件`app.groovy`：

```
@RestController
class ThisWillActuallyRun {

    @RequestMapping("/")
    String home() {
        "Hello World!"
    }

}
```

然后执行`$ spring run app.groovy`，第一次执行会下载依赖，会慢一些，之后就很快了，通过`localhost:8080`可以访问这个应用。

如果想指定别的端口：

```
$ spring run hello.groovy -- --server.port=9000
```

这里的`--`用于区分传递给spring应用的参数和传递给cli的参数。

## 新建项目
Spring Boot CLI可以新建项目，他其实是调用start.spring.io来新建项目。比如：

```
$ spring init --dependencies=web,data-jpa my-project
Using service at https://start.spring.io
Project extracted to '/Users/developer/example/my-project'
```

这样就不用去网站上新建项目再下载下来了。通过可以查看有哪些可以使用的构建工具和依赖：

```
$ spring init --list
=======================================
Capabilities of https://start.spring.io
=======================================

Available dependencies:
-----------------------
actuator - Actuator: Production ready features to help you monitor and manage your application
...
web - Web: Support for full-stack web development, including Tomcat and spring-webmvc
websocket - Websocket: Support for WebSocket development
ws - WS: Support for Spring Web Services

Available project types:
------------------------
gradle-build -  Gradle Config [format:build, build:gradle]
gradle-project -  Gradle Project [format:project, build:gradle]
maven-build -  Maven POM [format:build, build:maven]
maven-project -  Maven Project [format:project, build:maven] (default)

...
```

一个更加完整的用法：

```
$ spring init --build=gradle --java-version=1.8 --dependencies=websocket --packaging=war sample-app.zip
Using service at https://start.spring.io
Content saved to 'sample-app.zip'
```

## 参考资料
- [Spring Boot Reference Guide](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#cli)
