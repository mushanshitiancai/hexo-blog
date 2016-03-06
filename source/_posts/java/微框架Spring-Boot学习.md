---
title: 微框架Spring Boot介绍与入门
date: 2016-03-04 08:38:29
tags: java
---

Spring Boot的介绍可以看[这篇文章](http://www.infoq.com/cn/articles/microframeworks1-spring-boot)。总得来说，就是Spring也觉得自己用起来和什么PHP web框架啊，ROR框架啊，Python web框架啊相比太麻烦了，自己也不好意思了，现在大伙又喜欢推崇什么'微框架'(参考[文章](http://www.infoq.com/cn/news/2015/06/Java-Spark-Jodd-Ninja/))，讲究的就是灵活，简洁，易测试，易部署。所以Spring作为Java框架的老大，就祭出了Spring Boot这么一个东西。在Spring强大的基础上，弄了很多简化配置，部署的功能。

以下主要参考[Spring Boot的官网文档](http://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#getting-started-first-application)。

## 安装
我使用sdkman来安装Spring boot。sdkman的教程请看[SDKMAN的安装与使用 | 木杉的博客](http://mushanshitiancai.github.io/2016/03/04/java/SDKMAN%E7%9A%84%E5%AE%89%E8%A3%85%E4%B8%8E%E4%BD%BF%E7%94%A8/)。

```
$ sdk install springboot
$ spring --version
Spring Boot v1.3.3.RELEASE
```

## Hello World
spring boot宣传的时候，重点渲染的就是他比传统Spring能更快的搭建起来，更快的出原型，那到底有多快？我们做个hello world试试。

```
@RestController
class ThisWillActuallyRun {

    @RequestMapping("/")
    String home() {
        "Hello World!"
    }

}
```

把上面的代码写入`app.groovy`，然后执行：

    spring run app.groovy

第一次执行的时候，Spring boot需要下载依赖，所以会比较慢。之后启动就不会了。

启动成功后浏览器中打开`http://localhost:8080/`，就可以看到`Hello World!`啦。

虽然一个文件就可以弄个demo对于PHP，Python之流是家常便饭，但是对于Java，对于Spring，还是一件令人兴奋事情的。。。

## 搭建一个正经的应用
大部分情况下，我们还是会使用java来开发应用的，那怎么用Spring boot搭建一个传统的web应用呢？

### 新建POM
首先确保你安装了jdk和maven。然后新建`pom.xml`

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>myproject</artifactId>
    <version>0.0.1-SNAPSHOT</version>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.3.3.RELEASE</version>
    </parent>

    <!-- Additional lines to be added here... -->

</project>
```

运行`mvn package`来测试一下，同时也下载依赖。如果maven下载很慢的话，可以使用开源中国的maven库([开源中国 Maven 库](http://maven.oschina.net/help.html))。

### 添加必要的依赖
Spring boot提供了很多有用的“Starter POMs”，这些POM可以让我们快速的新建POM，刚刚建立的`pom.xml`中，继承了`spring-boot-starter-parent`。我们现在开发的是一个web应用，所以还得添加`spring-boot-starter-web`这个依赖。添加下面的代码到`</parent>`标签后面：

```
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
</dependencies>
```

运行`mvn dependency:tree`，可以看到现在项目有了好多依赖。

### 添加代码
现在我们要用java来写之前用groovy写的hello world。添加文件`src/main/java/Example.java`：

```
import org.springframework.boot.*;
import org.springframework.boot.autoconfigure.*;
import org.springframework.stereotype.*;
import org.springframework.web.bind.annotation.*;

@RestController
@EnableAutoConfiguration
public class Example {

    @RequestMapping("/")
    String home() {
        return "Hello World!";
    }

    public static void main(String[] args) throws Exception {
        SpringApplication.run(Example.class, args);
    }

}
```

`@RestController`和`@RequestMapping("/")`都是Spring MVC的注解。`@EnableAutoConfiguration`注解表示Spring boot会根据“Starter POMs”中的内容自动配置。

代码中包含了`main`方法。这是Spring boot和传统java web开发的不同之处了，Spring boot为了做到快速搭建，快速开发，快速部署，使用了内嵌的tomcat，所以可以直接运行，而不需要外部的容器。而且使用Spring boot的应用可以直接打包成一个可执行的jar，是非常方便的。

### 运行应用
因为使用maven管理项目，所以也使用maven运行项目。

    $ mvn spring-boot:run

启动后浏览器访问`http://localhost:8080/`就看到`Hello World!`啦！

### 打包应用
我们现在打包一个可以直接运行的jar文件（也称为“fat jars”，她包含了所有的依赖）。

添加代码到`dependencies`部分后面：

```
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>
```

运行`mvn package`后再`target`目录下会看到一个`myproject-0.0.1-SNAPSHOT.jar`，这文件有十几MB。还会有一个`myproject-0.0.1-SNAPSHOT.jar.original`，这是mvn普通打包的jar，没有被Spring boot重新打包，只包含本项目的类，他就很小了，只有几K。

可以查看`myproject-0.0.1-SNAPSHOT.jar`中的类：

    $ jar tvf target/myproject-0.0.1-SNAPSHOT.jar

可以使用java命令来运行这个jar文件：

```
$ java -jar target/myproject-0.0.1-SNAPSHOT.jar

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v1.3.3.RELEASE)

...
```

## 问题
### Spring可以做到热更新代码么?
保存文件后，刷新网页就可以看到效果，这个是PHP之流说Java之流傻逼的铁证。个人觉得也是PHP在web开发上，使用比例远比Java高的原因之一。谁不想保存代码就能看到效果呢。

Spring boot也考虑到了这一点，推出了`spring-boot-devtools`。他会监视classpath，一旦发现有类文件更新了，就自动重启。

启用方法很简单，加入`spring-boot-devtools`就可以了：

```
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-devtools</artifactId>
        <optional>true</optional>
    </dependency>
</dependencies>
```

这个功能需要结合IDE使用，因为IDE会在保存的时候更新class文件（目前我是这么理解的）。

1. [78. Hot swapping](http://docs.spring.io/spring-boot/docs/current/reference/html/howto-hotswapping.html)
2. [20. Developer tools](http://docs.spring.io/spring-boot/docs/current/reference/html/using-boot-devtools.html)
3. [DevTools in Spring Boot 1.3](https://spring.io/blog/2015/06/17/devtools-in-spring-boot-1-3)

这三个连接是更详细的说明，还是搞不明白，可以看看第三个连接的视频（我就是倒腾半天看了视频才弄清楚的。。。）。

### `spring-boot-devtools`每次都会重启应用，还是有点慢，还可以更快么？
可以！

有两个方案，`JRebel`和`Spring Loaded`。前者更屌，但是收费，后者开源，所以可以考虑使用后者。

`Spring Loaded`的使用会再出一篇文章，敬请期待。

## 参考文章
-  [深入学习微框架：Spring Boot](http://www.infoq.com/cn/articles/microframeworks1-spring-boot)
- [Spring Boot——开发新一代Spring Java应用 | 天码营 - 新一代技术学习服务平台](http://www.tianmaying.com/tutorial/spring-boot-overview)
- [Spring Boot](http://projects.spring.io/spring-boot/#quick-start)
- [Spring Boot Reference Guide](http://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/)
