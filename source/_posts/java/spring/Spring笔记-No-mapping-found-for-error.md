---
title: 'Spring笔记-No mapping found for HTTP request with URI [/] in DispatcherServlet问题解决'
date: 2017-03-13 10:21:58
categories: [Java,Spring]
tags: [java,spring]
---

周末在一个现有Spring项目中添加mvc配置，测试一下，发现提示错误：

```
No mapping found for HTTP request with URI [/] in DispatcherServlet with name 'console'
```

<!-- more -->

这就奇怪了，配置很简单，就是在web.xml中添加Spring MVC的servlet：

```xml
<servlet>
        <servlet-name>console</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <load-on-startup>1</load-on-startup>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>classpath:spring/search-console.xml</param-value>
        </init-param>
    </servlet>
    
    <servlet-mapping>
        <servlet-name>console</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:aop="http://www.springframework.org/schema/aop" xmlns:mvc="http://www.springframework.org/schema/mvc"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop.xsd http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc.xsd">

    <mvc:annotation-driven/>
    <context:component-scan base-package="com.facishare.search.console"/>

    <bean id="viewResolver" class="org.springframework.web.servlet.view.InternalResourceViewResolver">
        <property name="prefix" value="/WEB-INF/views/"/>
        <property name="suffix" value=".jsp"/>
    </bean>
</beans>
```

```java
@Controller
public class IndexController {
    @RequestMapping(value = "/")
    public String index(Model model){
        return "index";
    }
}
```

但是就是死活无法访问"/"这个地址。。。。。

最后在stackoverflow上看到了一个回答：

![](/img/java-springmvc-no-mapping-for-root.png)

最后一点的意思是，在网站根目录不能有会被认为是默认页面的文件，比如：index.html,index.jsp,default.html等。

难道我中了这一招？一看项目结构，额，原来的项目里在WEB-INF下有一个index.html：

![](/img/java-springmvc-no-mapping-for-root-2.png)

删除这个文件后，就正常啦！


外一则：

```xml
<mvc:resources mapping="/resources/**" location="/resources/"/>
```

这个是设置资源文件路由的，一定要记得，location的值，前后都需要有`/`，才能正确的路由。