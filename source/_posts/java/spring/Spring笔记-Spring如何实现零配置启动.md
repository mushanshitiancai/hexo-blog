---
title: Spring笔记-Spring如何实现零配置启动
date: 2017-05-23 17:45:25
categories: [Java,Spring]
tags: [java,spring]
---

看到一些Spring的项目，其`web.xml`是空的，但是Spring环境依然正确启动了，颇感好奇。原来这是在Servlet3推出后，Spring就跟进的功能。

<!-- more -->

Servlet3中，提供了新的注解，可以不依赖`web.xml`声明Servlet/过滤器/监听器。同时还提供了一个`ServletContainerInitializer`接口，这个接口能够让库代码加入到应用的启动环境中来。这个特性可以看看前一篇文章：？？。Spring就是利用了这个接口来实现零配置启动。

说明一下，这里的零配置指的是没有`web.xml`中的配置，而不是指Spring本身的配置。

## Spring零配置如何使用

一个典型的`web.xml`配置可能像这样（[参考](http://xxgblog.com/2015/07/09/spring-zero-xml/)）：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://java.sun.com/xml/ns/javaee"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
	version="3.0">

	<context-param>
		<param-name>contextConfigLocation</param-name>
		<param-value>classpath:applicationContext.xml</param-value>
	</context-param>
	<servlet>
		<servlet-name>dispatcher</servlet-name>
		<servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
		<init-param>
			<param-name>contextConfigLocation</param-name>
			<param-value>classpath:dispatcher-servlet.xml</param-value>
		</init-param>
		<load-on-startup>1</load-on-startup>
	</servlet>
	<servlet-mapping>
		<servlet-name>dispatcher</servlet-name>
		<url-pattern>/</url-pattern>
	</servlet-mapping>
	<listener>
		<listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
	</listener>

</web-app>
```

如果使用Spring零配置特性，以上的xml就变成如下的Java代码：

```java
public class MyWebAppInitializer implements WebApplicationInitializer {

	/**
	 * Servlet容器启动时会自动运行该方法
	 */
	@Override
	public void onStartup(ServletContext servletContext) throws ServletException {

		servletContext.setInitParameter("contextConfigLocation", "classpath:applicationContext.xml");

		ServletRegistration.Dynamic registration = servletContext.addServlet("dispatcher", new DispatcherServlet());
		registration.setLoadOnStartup(1);
		registration.addMapping("/");
		registration.setInitParameter("contextConfigLocation", "classpath:dispatcher-servlet.xml");

		servletContext.addListener(new ContextLoaderListener());
	}
}
```

为什么应用中只要实现了Spring提供的`WebApplicationInitializer`接口，应用在启动的时候就会触发`onStartup`方法呢？

## Spring零配置代码分析

首先可以看到spring-web中定义了`javax.servlet.ServletContainerInitializer`这个文件，其中指定了`org.springframework.web.SpringServletContainerInitializer`这个实现类：

![](/img/java/servlet/spring-servlet-initializer.png)

实现类的代码如下：

```java
// 说明只处理WebApplicationInitializer的实现类
@HandlesTypes(WebApplicationInitializer.class)
public class SpringServletContainerInitializer implements ServletContainerInitializer {

    // 应用启动时会触发该方法
	@Override
	public void onStartup(Set<Class<?>> webAppInitializerClasses, ServletContext servletContext)
			throws ServletException {

		List<WebApplicationInitializer> initializers = new LinkedList<WebApplicationInitializer>();

		if (webAppInitializerClasses != null) {
			for (Class<?> waiClass : webAppInitializerClasses) {
				// 过滤用户定义的WebApplicationInitializer的合法实现类
				if (!waiClass.isInterface() && !Modifier.isAbstract(waiClass.getModifiers()) &&
						WebApplicationInitializer.class.isAssignableFrom(waiClass)) {
					try {
						initializers.add((WebApplicationInitializer) waiClass.newInstance());
					}
					catch (Throwable ex) {
						throw new ServletException("Failed to instantiate WebApplicationInitializer class", ex);
					}
				}
			}
		}

        // 如果用户没有定义WebApplicationInitializer的实现类，那么说明用户没有使用Spring零配置特性
		if (initializers.isEmpty()) {
			servletContext.log("No Spring WebApplicationInitializer types detected on classpath");
			return;
		}

		servletContext.log(initializers.size() + " Spring WebApplicationInitializers detected on classpath");
		AnnotationAwareOrderComparator.sort(initializers);

        // 调用WebApplicationInitializer的实现类的初始化方法
		for (WebApplicationInitializer initializer : initializers) {
			initializer.onStartup(servletContext);
		}
	}
}
```

`SpringServletContainerInitializer`是一个很简单的包装，作为应用启动触发的入口。其中把启动的流程转发到了`WebApplicationInitializer`实现类中。

## Spring零配置别的使用方法

除了直接实现`WebApplicationInitializer`接口外，Spring还提供了一些实现了部分功能的抽象类来方便我们使用，就行`HttpServlet`之于`Servlet`一样：

- org.springframework.web.context.AbstractContextLoaderInitializer
- org.springframework.web.servlet.support.AbstractDispatcherServletInitializer
- org.springframework.web.servlet.support.AbstractAnnotationConfigDispatcherServletInitializer

![](/img/java/servlet/spring-app-initializer-uml.png)

一般比较常见的做法是基础`AbstractAnnotationConfigDispatcherServletInitializer`这个类，实现其`getRootConfigClasses`和`getServletConfigClasses`这两个方法，在这两个方法中指定Spring的配置类。

## 参考资料
- [Servlet 3 + Spring MVC零配置：去除所有xml | 叉叉哥的BLOG](http://xxgblog.com/2015/07/09/spring-zero-xml/)