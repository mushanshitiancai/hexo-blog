---
title: RESTEasy与Spring整合
date: 2016-08-22 16:54:12
categories: [Java,Spring]
tags: [java,spring]
---

RESTEasy是一个用于开发REST风格应用的库，和Spring结合在一起使用是非常常见的解决方案。

## 添加依赖
Spring那一坨依赖就不说了，说一下需要添加的RESTEasy依赖：

```
<resteasy.version>3.0.13.Final</resteasy.version>

<!-- Basic support -->
<dependency>
    <groupId>org.jboss.resteasy</groupId>
    <artifactId>resteasy-jaxrs</artifactId>
    <version>${resteasy.version}</version>
</dependency>
<!-- Servlet pluggability support -->
<dependency>
    <groupId>org.jboss.resteasy</groupId>
    <artifactId>resteasy-servlet-initializer</artifactId>
    <version>${resteasy.version}</version>
</dependency>
<!-- JSON/POJO support -->
<dependency>
    <groupId>org.jboss.resteasy</groupId>
    <artifactId>resteasy-jackson2-provider</artifactId>
    <version>${resteasy.version}</version>
</dependency>
<!-- REST Client support -->
<dependency>
    <groupId>org.jboss.resteasy</groupId>
    <artifactId>resteasy-client</artifactId>
    <version>${resteasy.version}</version>
</dependency>
<!-- Spring support -->
<dependency>
  <groupId>org.jboss.resteasy</groupId>
  <artifactId>resteasy-spring</artifactId>
  <version>${resteasy.version}</version>
</dependency>
```

## 修改web.xml

RESTEasy和Spring结合时的侵入还是比较严重的，因为他需要使用他自己实现的Spring ContextLoaderListener。在这个ContextLoaderListener中，RESTEasy在每个Bean新建时检测是否是被JAX-RS注解的。如果是就注册为JAX-RS资源。

所以修改web.xml如下：

```
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">

    <display-name>Archetype Created Web Application</display-name>

    <listener>
        <listener-class>org.jboss.resteasy.plugins.server.servlet.ResteasyBootstrap</listener-class>
    </listener>

    <listener>
        <listener-class>org.jboss.resteasy.plugins.spring.SpringContextLoaderListener</listener-class>
    </listener>

    <servlet>
        <servlet-name>Resteasy</servlet-name>
        <servlet-class>org.jboss.resteasy.plugins.server.servlet.HttpServletDispatcher</servlet-class>
    </servlet>

    <servlet-mapping>
        <servlet-name>Resteasy</servlet-name>
        <url-pattern>/*</url-pattern>
    </servlet-mapping>

</web-app>
```

这里是把所有的请求都用RESTEasy处理，如果你想设置其他路径下的请求，见下文。

## 编写REST处理器（Controller）

```
@Path("/")
public class Test {

    @GET
    @Path("/")
    public String index(){
        return "index";
    }

    @POST
    @Path("/test")
    public String test(){
        return "test";
    }
}
```

这些注解还是很名义的。

## 建立Spring配置

Spring配置没有特别的，在WEB-INF中建立applicationContext.xml：

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean class="com.mushan.Test" />
</beans>
```

然后运行，访问`/`即可看到输出。

## 指定RESTEasy处理非`/*`下的请求

如果你想配置，修改url-pattern即可，但是一定要注意，传递该RESTEasy的，是完整的路径，所以你在@PATH注解处理路径时，不要忘了前缀。说起来不清楚，举个例子：

比如我的网站只有`rest/*`下的URL是处理REST请求的，那么我可以这么配置：

```
<servlet-mapping>
   <servlet-name>Resteasy</servlet-name>
   <url-pattern>/rest/*</url-pattern>
</servlet-mapping>
```

你的REST处理器要这么写：

```
@Path("/rest")
public class Test {
    @GET
    @Path("/")
    public String index(){
        return "index";
    }
```

也就是必须带着`/rest`这个前缀。

这样虽然程序能走通，但是有一个严重的问题，就是`/rest`这个URL配置写死在代码里了，导致之后如果要变动会非常麻烦。这里我们可以使用`resteasy.servlet.mapping.prefix`这个配置：

```
<context-param>
    <param-name>resteasy.servlet.mapping.prefix</param-name>
    <param-value>/rest</param-value>
</context-param>

<servlet-mapping>
   <servlet-name>Resteasy</servlet-name>
   <url-pattern>/rest/*</url-pattern>
</servlet-mapping>
```

这样处理器里就不用写出前缀了：

```
@Path("/")
public class Test {
    @GET
    @Path("/")
    public String index(){
        return "index";
    }
```

## 其他

如果你遇到错误：

```
java.lang.NoClassDefFoundError: org/springframework/web/servlet/HandlerAdapter
```

这是因为还需要引入Spring-mvc的依赖。

## 参考资料
- [RESTEasy JAX-RS](http://docs.jboss.org/resteasy/docs/3.0.19.Final/userguide/html_single/index.html#RESTEasy_Spring_Integration)

