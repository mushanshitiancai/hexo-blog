---
title: Spring学习-ContextLoaderListener启动流程
date: 2017-06-17 17:16:20
categories: [Java,Spring]
tags: [java,spring]
---

我们在配置Spring WEB项目的时候，通常会有这样的配置：

```xml
<listener>
   <listenerclass>
     org.springframework.web.context.ContextLoaderListener
   </listener-class>
</listener>
 
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>classpath:config/applicationContext.xml</param-value>
</context-param>
```

在部署描述符中指定`ContextLoaderListener`，通过这个Listener来读取xml配置，达到启动Spring应用上下文的目的。今天我们来看看`ContextLoaderListener`是如何启动Spring容器的。

<!-- more -->

`ContextLoaderListener`启动的流程图如下：

![](/img/java/spring/ContextLoaderListener-start-flow.png)

我们来看看`ContextLoaderListener`的代码，`ContextLoaderListener`主要是实现了`ServletContextListener`的启动和销毁方法，具体的逻辑实现在父类`ContextLoader`中：

```java
public class ContextLoaderListener extends ContextLoader implements ServletContextListener {

    // 基于部署描述符的配置，会使用空构造函数
	public ContextLoaderListener() {
	}

    // 基于JavaConfig的配置会使用该构造函数，传入WebApplicationContext实现（见下文）
	public ContextLoaderListener(WebApplicationContext context) {
		super(context);
	}

    // 应用初始化时调用，这里是初始化Spring Web ApplicationContext的入口
	@Override
	public void contextInitialized(ServletContextEvent event) {
		initWebApplicationContext(event.getServletContext());
	}

	@Override
	public void contextDestroyed(ServletContextEvent event) {
		closeWebApplicationContext(event.getServletContext());
		ContextCleanupListener.cleanupAttributes(event.getServletContext());
	}
}
```

`initWebApplicationContext`函数定义在`ContextLoader`上，实例化并初始化WebApplicationContext:

```java
public WebApplicationContext initWebApplicationContext(ServletContext servletContext) {
	// 判断是否已经有Root WebApplicationContext，如果已经存在，说明重复声明ContextLoader了
	if (servletContext.getAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE) != null) {
		throw new IllegalStateException(
				"Cannot initialize context because there is already a root application context present - " +
				"check whether you have multiple ContextLoader* definitions in your web.xml!");
	}

	Log logger = LogFactory.getLog(ContextLoader.class);
	servletContext.log("Initializing Spring root WebApplicationContext");
	if (logger.isInfoEnabled()) {
		logger.info("Root WebApplicationContext: initialization started");
	}
	long startTime = System.currentTimeMillis();

	try {
		// 保存context到实例变量中，在ServletContext销毁的时候用于清理资源
		if (this.context == null) {  // (1)
			// 新建WebApplicationContext
			this.context = createWebApplicationContext(servletContext);
		}
		if (this.context instanceof ConfigurableWebApplicationContext) {
			ConfigurableWebApplicationContext cwac = (ConfigurableWebApplicationContext) this.context;
			if (!cwac.isActive()) {
				// WebApplicationContext还没激活，需要设置并启动
				if (cwac.getParent() == null) {
					ApplicationContext parent = loadParentContext(servletContext);
					cwac.setParent(parent);
				}
				configureAndRefreshWebApplicationContext(cwac, servletContext);
			}
		}
		// 把WebApplicationContext实例添加到servletContext中
		servletContext.setAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE, this.context);

		ClassLoader ccl = Thread.currentThread().getContextClassLoader();
		if (ccl == ContextLoader.class.getClassLoader()) {
			currentContext = this.context;
		}
		else if (ccl != null) {
			currentContextPerThread.put(ccl, this.context);
		}

		if (logger.isDebugEnabled()) {
			logger.debug("Published root WebApplicationContext as ServletContext attribute with name [" +
					WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE + "]");
		}
		if (logger.isInfoEnabled()) {
			long elapsedTime = System.currentTimeMillis() - startTime;
			logger.info("Root WebApplicationContext: initialization completed in " + elapsedTime + " ms");
		}

		return this.context;
	}
	catch (RuntimeException ex) {
		logger.error("Context initialization failed", ex);
		servletContext.setAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE, ex);
		throw ex;
	}
	catch (Error err) {
		logger.error("Context initialization failed", err);
		servletContext.setAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE, err);
		throw err;
	}
}
```

注意一点，在(1)这个分支处。如果是使用基于xml的配置，那么`this.context == null`成立，会调用`createWebApplicationContext`来新建WebApplicationContext，默认使用`XmlWebApplicationContext`来作为WebApplicationContext实现。也可以使用`contextClass`参数来手动指定使用的`WebApplicationContext`实现类，举个例子：

```xml
<context-param>
    <param-name>contextClass</param-name>
    <param-value>
        org.springframework.web.context.support.AnnotationConfigWebApplicationContext
    </param-value>
</context-param>

<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>com.mushan.AppConfig</param-value>
</context-param>
```

如果是基于javaconfig配置，那么在`AbstractContextLoaderInitializer`启动时，默认会使用`AnnotationConfigWebApplicationContext`来初始化ContextLoaderListener，见代码：

```java
public abstract class AbstractContextLoaderInitializer implements WebApplicationInitializer {

    // 实例化ContextLoaderListener，并且传入构造好的rootAppContext
	protected void registerContextLoaderListener(ServletContext servletContext) {
		WebApplicationContext rootAppContext = createRootApplicationContext();
		if (rootAppContext != null) {
			servletContext.addListener(new ContextLoaderListener(rootAppContext));
		}
		else {
			logger.debug("No ContextLoaderListener registered, as " +
					"createRootApplicationContext() did not return an application context");
		}
	}

    // 使用什么作为rootAppContext由子类决定
    protected abstract WebApplicationContext createRootApplicationContext();

    ...
}
```

我们一般使用`AbstractAnnotationConfigDispatcherServletInitializer`，所以`createRootApplicationContext`函数在上面得到了实现：

```java
protected WebApplicationContext createRootApplicationContext() {
    Class<?>[] configClasses = getRootConfigClasses();
    if (!ObjectUtils.isEmpty(configClasses)) {
        AnnotationConfigWebApplicationContext rootAppContext = new AnnotationConfigWebApplicationContext();
        rootAppContext.register(configClasses);
        return rootAppContext;
    }
    else {
        return null;
    }
}
```

这里可以看到是用了`AnnotationConfigWebApplicationContext`作为实现了。

层次关系示意图：

![](/img/java/spring/ContextLoaderListener-start-flow-java-config.png)

## 总结

- ContextLoaderListener是Web应用启动Spring应用上下文的入口
- 基于部署描述符配置，默认使用`XmlWebApplicationContext`作为`WebApplicationContext`实现类
- 基于JavaConfig配置，默认使用`AnnotationConfigWebApplicationContext`作为`WebApplicationContext`实现类
- ContextLoaderListener会持有`WebApplicationContext`实例，用于销毁
- 同时ContextLoaderListener会把`WebApplicationContext`实例注册到ServletContext中