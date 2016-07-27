---
title: 为什么JSP中默认无法使用JSTL
date: 2016-07-27 11:54:09
categories: [Java]
tags: java
---

用maven新建了一个SpringMVC工程，在JSP中用`${param}`这样的语法输出Controller传来的参数，运行发现并没有替换为具体的变量，而是原样输出了，这是为什么？

我的运行环境是：Java 1.8,Tomcat 8.0.28

`${}`是JSTL的语法，这个语法没有被解析，所以应该是JSTL没有被引入或者是JSTL没有被开启。运行时，JSTL的依赖是容器提供的，所以应该不是依赖的问题。后得知在JSP文件中加入：

```
<%@ page isELIgnored="false" %>
```

输出就正常了。为什么默认情况下EL表达式被禁用了呢？oracle官网上有这么一段：

> The default value of isELIgnored varies depending on the version of the web application deployment descriptor. The default mode for JSP pages delivered with a Servlet 2.4 descriptor is to evaluate EL expressions; this automatically provides the default that most applications want. The default mode for JSP pages delivered using a descriptor from Servlet 2.3 or before is to ignore EL expressions; this provides backward compatibility.

也就是说，isELIgnored这个属性的默认值由容器决定，如果是Servlet 2.4以及之后的版本，这个值默认为false，也就是说会执行EL表达式。Servlet 2.3以及更早的版本，是不会处理EL表达式的。

那我使用的Tomcat其中内置的Servlet版本是多少呢？可以参考这个网页：[Apache Tomcat® - Which Version Do I Want?](http://tomcat.apache.org/whichversion.html)，其中列出了每个版本的Tomcat对应的Servlet，JSP等版本。

我所使用的Tomcat 8.0.28内置的Servlet版本是3.1，大于2.4，为什么EL表达式还是不能生效呢？

原来一个项目使用哪个版本的Servlet规范不是直接由容器的Servlet版本决定的，而是在web.xml中指定的，容器的Servlet版本只是决定了你最高可以用到哪个版本的特性。

我的项目的web.xml的第一句：

```
<!DOCTYPE web-app PUBLIC
        "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
        "http://java.sun.com/dtd/web-app_2_3.dtd" >
<web-app>
```

也就是maven在新建maven-archetype-webapp类型的工程时，默认新建的是Servlet 2.3版本的工程。所以EL表达式也就无效了。

知道了这个原因后，根据需求，如果你就是需要建立Servlet 2.3版本的工程，你就在JSP页面中加入`<%@ page isELIgnored="false" %>`，如果是想要建立新的版本的Servlet的工程，那么就更改web.xml，比如我想要新建Servlet 3.1版本的，我就这样修改web.xml：

```
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">
```

新手一个，犯的错误也比较低级，供参考。不过Java Web这个不同版本Servlet的区别，还是比较蛋疼的，然后不同版本的web.xml格式也没法记忆，只能网上找一段然后复制粘贴，感觉不太严谨。

## 参考资料
- [Deactivating Expression Evaluation (The Java EE 5 Tutorial)](https://docs.oracle.com/cd/E19575-01/819-3669/bnaic/index.html)
