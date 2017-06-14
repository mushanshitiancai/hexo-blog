---
title: Spring笔记-文件上传
date: 2017-06-14 13:44:44
categories: [Java,Spring]
tags: [java,spring]
---

在[Servlet3笔记-文件上传 | 木杉的博客](http://mushanshitiancai.github.io/2017/06/14/java/servlet/Servlet3%E7%AC%94%E8%AE%B0-%E6%96%87%E4%BB%B6%E4%B8%8A%E4%BC%A0/)中提到过，Servlet3.0以前，处理上传文件是非常麻烦的。而SpringMVC包装了这个复杂性，我们可以很方便的在任何Servlet版本上方便的处理上传文件。

<!-- more -->

## 原理

在Servlet3.0之前获取文件的方式，是通过手动解析Request来实现的，使用`commons-fileupload.jar`和`commons-io.jar`这两个依赖解析Multipart格式的请求体，具体的方法网上很多，比如[这篇](http://www.cnblogs.com/hanyuan/archive/2012/06/09/upload.html)。

而SpringMVC就是吧这些代码帮我们写好了。原理是一样的。在处理请求时，Spring会看是否存在一个叫做`multipartResolver`的Bean，如果有，那么在处理请求时，会使用对应的multipartResolver来处理格式为`multipart/form-data`的请求体，同时把普通的`HttpServletRequest`替换为可以操作上传文件的`MultipartHttpServletRequest`。

## 使用

因为Spring提供的`CommonsMultipartResolver`使用Apache Commons FileUpload来实现请求解析，所以需要添加依赖：

```xml
<!-- Apache Commons FileUpload -->
<dependency>
    <groupId>commons-fileupload</groupId>
    <artifactId>commons-fileupload</artifactId>
    <version>1.3.1</version>
</dependency>

<!-- Apache Commons IO -->
<dependency>
    <groupId>commons-io</groupId>
    <artifactId>commons-io</artifactId>
    <version>2.4</version>
</dependency>
```

然后添加MultipartResolver的Bean：

```java
@Bean
public MultipartResolver multipartResolver() {
    CommonsMultipartResolver resolver = new CommonsMultipartResolver();
    resolver.setDefaultEncoding("utf-8");
    resolver.setMaxUploadSize(5 * 1024 * 1024);
    resolver.setMaxInMemorySize(512 * 1024);
    return resolver;
}
```

xml配置的话这么写：

```xml
<beans:bean id="multipartResolver" class="org.springframework.web.multipart.commons.CommonsMultipartResolver">
        <!-- setting maximum upload size -->
    <beans:property name="maxUploadSize" value="100000" />
</beans:bean>
```

然后对应的Controller处理方法上，可以使用`@RequestParam("file") MultipartFile file`，`@RequestParam("file") MultipartFile[] files`来获取单个或者多个上传文件。

同时，传入方法的Request具体类型变为`MultipartHttpServletRequest`，可以根据需要进行类型转换后调用`MultipartHttpServletRequest`上的方法。

## 原理之代码层面

DispatcherServlet在初始化时会尝试加载容器中的`MultipartResolver`，流程如下：

![](/img/java/spring/init-MultipartResolver.png)

具体读取代码为：

```java
private void initMultipartResolver(ApplicationContext context) {
    try {
        this.multipartResolver = context.getBean(MULTIPART_RESOLVER_BEAN_NAME, MultipartResolver.class);
        if (logger.isDebugEnabled()) {
            logger.debug("Using MultipartResolver [" + this.multipartResolver + "]");
        }
    }
    catch (NoSuchBeanDefinitionException ex) {
        // Default is no multipart resolver.
        this.multipartResolver = null;
        if (logger.isDebugEnabled()) {
            logger.debug("Unable to locate MultipartResolver with name '" + MULTIPART_RESOLVER_BEAN_NAME +
                    "': no multipart request handling provided");
        }
    }
}
```

很简单，就是读取名字为`MULTIPART_RESOLVER_BEAN_NAME`指定的（默认为`multipartResolver`），类型为`MultipartResolver`的Bean。

在处理请求时，DispatcherServlet会调用方法来处理Request：

```java
protected HttpServletRequest checkMultipart(HttpServletRequest request) throws MultipartException {
    if (this.multipartResolver != null && this.multipartResolver.isMultipart(request)) {
        if (WebUtils.getNativeRequest(request, MultipartHttpServletRequest.class) != null) {
            logger.debug("Request is already a MultipartHttpServletRequest - if not in a forward, " +
                    "this typically results from an additional MultipartFilter in web.xml");
        }
        else if (hasMultipartException(request) ) {
            logger.debug("Multipart resolution failed for current request before - " +
                    "skipping re-resolution for undisturbed error rendering");
        }
        else {
            try {
                return this.multipartResolver.resolveMultipart(request);
            }
            catch (MultipartException ex) {
                if (request.getAttribute(WebUtils.ERROR_EXCEPTION_ATTRIBUTE) != null) {
                    logger.debug("Multipart resolution failed for error dispatch", ex);
                    // Keep processing error dispatch with regular request handle below
                }
                else {
                    throw ex;
                }
            }
        }
    }
    // If not returned before: return original request.
    return request;
}
```


## 参考资料
- [Spring MVC File Upload Example Tutorial - Single and Multiple Files - JournalDev](http://www.journaldev.com/2573/spring-mvc-file-upload-example-single-multiple-files)