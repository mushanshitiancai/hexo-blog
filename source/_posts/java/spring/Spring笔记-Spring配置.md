---
title: Spring笔记-Spring配置
date: 2017-06-07 17:20:53
categories: [Java,Spring]
tags: [java,spring]
---

对于spring的配置，分为两块，我把它们称之为：

- 启动配置：Spring是集成到我们的应用中使用的，所以不同的应用有不同的方式来启动spring。最常见的场景是web应用，启动的配置在web.xml部署描述符中。对于其他的Java程序，可能通过代码调用的方式直接启动Spring，那么就没有启动配置了。
- 容器配置：Spring容器的配置，一般的名字是applicationContext.xml，指挥Spring如何搜索，装配Bean。

<!-- more -->

在Java Web中使用Spring大致是这个结构：

![](/img/java/spring/xml-config.png)

接下来我们来看看最精简的Java Web+Spring配置，然后在根据需求不断扩展。

首先新建一个Java web项目。添加spring依赖：

```xml
<properties>
        <org.springframework.version>4.3.8.RELEASE</org.springframework.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>${org.springframework.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-web</artifactId>
            <version>${org.springframework.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-webmvc</artifactId>
            <version>${org.springframework.version}</version>
        </dependency>
    </dependencies>
```

在web.xml中加入配置：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">
    <!-- 指定Spring提供的ContextLoaderListener，这个Listener会启动Spring容器-->
    <listener>
        <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
    </listener>

    <!-- 这个参数指定哪里放置Spring容器配置文件 -->
    <context-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>classpath:applicationContext.xml</param-value>
    </context-param>
</web-app>
```

然后在resources目录下新建applicationContext.xml文件：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">

    <bean id="demoBean" class="com.mushan.spring.DemoBean"/>

</beans>
```

其中我们声明了一个实例用的Bean：

```java
public class DemoBean implements InitializingBean{
    public void afterPropertiesSet() throws Exception {
        System.out.println("init DemoBean");
    }
}
```

这里让Bean实现`InitializingBean`接口是因为其`afterPropertiesSet`方法会在Bean实例化时调用，这样我们就能感知到容器启动并实例化Bean了。

## Java Config配置

Servlet3支持使用Java代码作为部署描述符的补充。所以启动配置可以从web.xml中移到Java代码中。利用Spring的支持，我们只要实现`WebApplicationInitializer`接口即可。

同时Spring支持使用Java来替代以前所使用的基于xml的applicationContext.xml配置。

所以配置结构如图：

![](/img/java/spring/java-config.png)

启动配置代码如下：

```java
public class MyWebApplicationInitializer implements WebApplicationInitializer {

    public void onStartup(ServletContext servletContext) throws ServletException {
        ServletRegistration.Dynamic registration = servletContext.addServlet("test", new DispatcherServlet());
        registration.setLoadOnStartup(1);
        registration.addMapping("/test/*");
        registration.setInitParameter("contextClass", "org.springframework.web.context.support.AnnotationConfigWebApplicationContext");
        registration.setInitParameter("contextConfigLocation", "AppConfig");
    }
}
```

容器配置如下：

```java
@Configuration
public class AppConfig {

    @Bean
    public TestServlet testServlet(){
        return new TestServlet();
    }
}
```

同时Spring提供了`WebApplicationInitializer`接口的高层次封装`AbstractAnnotationConfigDispatcherServletInitializer`，只要实现其中的虚方法就行：

```java
public class GolfingWebAppInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {

    @Override
    protected Class<?>[] getRootConfigClasses() {
        // GolfingAppConfig defines beans that would be in root-context.xml
        return new Class[] { GolfingAppConfig.class };
    }

    @Override
    protected Class<?>[] getServletConfigClasses() {
        // GolfingWebConfig defines beans that would be in golfing-servlet.xml
        return new Class[] { GolfingWebConfig.class };
    }

    @Override
    protected String[] getServletMappings() {
        return new String[] { "/golfing/*" };
    }

}
```

## 参考资料
- [Spring Framework3文档](http://docs.spring.io/spring/docs/3.2.x/spring-framework-reference/htmlsingle/)
- [Spring Framework4文档](http://docs.spring.io/spring/docs/current/spring-framework-reference/htmlsingle/)