---
title: Spring笔记-异常处理
date: 2017-11-27 21:08:54
categories: [Java,Spring]
tags: [java,spring]
---

Spring MVC提供了好几种方法让我来定制异常的处理。

本文参考：[Exception Handling in Spring MVC](https://spring.io/blog/2013/11/01/exception-handling-in-spring-mvc)

<!-- more -->

## 为异常定制HTTP状态码

默认如果我们在controller中抛出异常，Spring MVC会给用户响应500页面，并包含详细的错误信息。

![](/img/spring-exception-500.png)

如果我们想修改错误对应的HTTP状态码，我们可以在对应的异常上面添加`@ResponseStatus`注解，通过这个注解我们可以设置这个异常对应的HTTP状态码和错误信息，例子：

```java
@Controller
public class ExceptionController {

    @RequestMapping("/")
    public void test(){
        throw new NotFoundException();
    }
}

@ResponseStatus(value = HttpStatus.NOT_FOUND, reason = "not found")
public class NotFoundException extends RuntimeException{

}
```

然后请求，可以发现页面不一样了：

![](/img/spring-exception-response-status-404.png)

## Controller级别的错误拦截处理

通过`@ResponseStatus`注解，我们虽然可以定制HTTP状态码和错误信息了，但是完全不够用。

第一，只能设置自己写的异常，对于已有的异常，无法进行扩展。

第二，无法定制错误页面，默认的错误页面我们基本是不会使用的。

对于以上两个问题，可以在Controller里添加方法来拦截处理异常。方法需要使用`@ExceptionHandler`注解。注解后，方法会拦截**当前**Controller的请求处理方法（被`@RequestMapping`注解的方法）所抛出的异常。同时这个异常拦截方法，可以返回视图，该视图用于渲染错误信息。同时还可以在这个异常拦截方法上，使用`@ResponseStatus`来实现对已有异常的HTTP状态码定制，具体看例子：

```java
@Controller
public class ExceptionHandlingController {

  // 请求处理方法
  ...
  
  // 异常处理方法
  
  // 定制一个已有异常的HTTP状态码
  @ResponseStatus(value=HttpStatus.CONFLICT,
                  reason="Data integrity violation")  // 409
  @ExceptionHandler(DataIntegrityViolationException.class)
  public void conflict() {
    // 啥也不干
  }
  
  // 指定view来渲染对应的异常
  @ExceptionHandler({SQLException.class,DataAccessException.class})
  public String databaseError() {
    // Nothing to do.  Returns the logical view name of an error page, passed
    // to the view-resolver(s) in usual way.
    // Note that the exception is NOT available to this view (it is not added
    // to the model) but see "Extending ExceptionHandlerExceptionResolver"
    // below.
    // 啥也不干，就返回异常页面view的名称
    // 注意这里的view访问不到异常，因为异常没有添加到model中
    return "databaseError";
  }

  // 拦截该Controller抛出的所有异常，同时把异常信息通过ModelAndView传给视图
  // 或者你可以继承ExceptionHandlerExceptionResolver来实现，见下文
  @ExceptionHandler(Exception.class)
  public ModelAndView handleError(HttpServletRequest req, Exception ex) {
    logger.error("Request: " + req.getRequestURL() + " raised " + ex);

    ModelAndView mav = new ModelAndView();
    mav.addObject("exception", ex);
    mav.addObject("url", req.getRequestURL());
    mav.setViewName("error");
    return mav;
  }
}
```

注意，使用`@ExceptionHandler`一定要指定处理的是哪个异常，否则会报异常：`java.lang.IllegalArgumentException: No exception types mapped to {public java.lang.String XXController.exceptionHandler()}`

## 全局异常处理

Controller级别的异常控制虽然已经够强大了，但是我们总不可能每个Controller都写一个handleError方法吧，所以我们一定需要一个全局的异常处理方法。借助`@ControllerAdvice`可以简单直接的实现这个需求。

`@ControllerAdvice`是Spring3.2添加的注解，和名字一样，这个注解提供了增强Controller的功能，可把advice类中的`@ExceptionHandler`、`@InitBinder`、`@ModelAttribute`注解的方法应用到所有的Controller中去。最常用的就是`@ExceptionHandler`了。本来我们需要在每个Controller中定义`@ExceptionHandler`，现在我们可以声明一个`@ControllerAdvice`类，然后定义一个统一的`@ExceptionHandler`方法。

比如上面的例子，用`@ControllerAdvice`的写法如下：

```java
@ControllerAdvice
class GlobalControllerExceptionHandler {
    @ResponseStatus(HttpStatus.CONFLICT)  // 409
    @ExceptionHandler(DataIntegrityViolationException.class)
    public void handleConflict() {
        // 啥也不干
    }
}
```

如果你想拦截所有错误，那其实和上面的Controller级别的例子一样，设置拦截的Exception为`Exception.class`即可。

```java
@ControllerAdvice
class GlobalDefaultExceptionHandler {
  public static final String DEFAULT_ERROR_VIEW = "error";

  @ExceptionHandler(value = Exception.class)
  public ModelAndView
  defaultErrorHandler(HttpServletRequest req, Exception e) throws Exception {
    // 这里需要注意一下，因为这个方法会拦截所有异常，包括设置了@ResponseStatus注解的异常，如果你不想拦截这些异常，可以过滤一下，然后重新抛出
    if (AnnotationUtils.findAnnotation
                (e.getClass(), ResponseStatus.class) != null)
      throw e;

    // 组装异常信息给视图
    ModelAndView mav = new ModelAndView();
    mav.addObject("exception", e);
    mav.addObject("url", req.getRequestURL());
    mav.setViewName(DEFAULT_ERROR_VIEW);
    return mav;
  }
}
```

## 更深层的拦截

上面说的Controller级别以及Controller Advice级别的拦截，是基于注解的，是高级特性。底层实现上，Spring使用的是`HandlerExceptionResolver`。

所有定义在`DispatcherServlet`应用上下文中的bean，只要是实现了`HandlerExceptionResolver`接口，都会用来异常拦截处理。

看一下接口的定义：

```java
public interface HandlerExceptionResolver {
    ModelAndView resolveException(HttpServletRequest request, 
            HttpServletResponse response, Object handler, Exception ex);
}
```

`handler`参数是抛出异常的Controller的引用。

Spring实现了几种`HandlerExceptionResolver`，这些类是上面提到的几个特性的基础：

- `ExceptionHandlerExceptionResolver`：判断异常是否可以匹配到对应Controller或者Controller Advice中的`@ExceptionHandler`方法，如果可以则触发（前文提到的异常拦截方法的特性就是这个类实现的）
- `ResponseStatusExceptionResolver`：判断异常是否被`@ResponseStatus`注解，如果是，则使用注解的信息来更新Response（前文提到的自定义HTTP状态码就是用这个特性实现的）
- `DefaultHandlerExceptionResolver`：转换Spring异常，并转换为HTTP状态码（Spring内部使用）

这几个`HandlerExceptionResolver`会按照这个顺序来执行，也就是异常处理链。

这里可以看到，`resolveException`方法签名中没有`Model`参数，所以`@ExceptionHandler`方法也不能注入这个参数，所以上文中，异常拦截方法只能自己新建Model。

所以，如果你需要，你可以自己继承`HandlerExceptionResolver`来实现自己的异常处理链。然后再实现`Ordered`接口，这样就可以控制处理器的执行顺序。

## SimpleMappingExceptionResolver

Spring提供了一个很方便使用的`HandlerExceptionResolver`，叫`SimpleMappingExceptionResolver`。他有很多实用的功能：

- 映射异常名称到视图名称（异常名称只需要指定类名，不需要包名）
- 指定一个默认的错误页面
- 把异常打印到log上
- 指定exception到视图中的属性名，默认的属性名就是exception。（`@ExceptionHandler`方法指定的视图默认没法获取异常，而`SimpleMappingExceptionResolver`指定的视图可以）

用法如下：

```xml
<bean id="simpleMappingExceptionResolver" class=
    "org.springframework.web.servlet.handler.SimpleMappingExceptionResolver">
    <property name="exceptionMappings">
        <map>
            <entry key="DatabaseException" value="databaseError"/>
            <entry key="InvalidCreditCardException" value="creditCardError"/>
        </map>
    </property>

    <!-- See note below on how this interacts with Spring Boot -->
    <property name="defaultErrorView" value="error"/>
    <property name="exceptionAttribute" value="ex"/>
        
    <!-- Name of logger to use to log exceptions. Unset by default, 
            so logging is disabled unless you set a value. -->
    <property name="warnLogCategory" value="example.MvcLogger"/>
</bean>
```

Java Configuration：

```java
@Configuration
@EnableWebMvc  // Optionally setup Spring MVC defaults (if you aren't using
               // Spring Boot & haven't specified @EnableWebMvc elsewhere)
public class MvcConfiguration extends WebMvcConfigurerAdapter {
  @Bean(name="simpleMappingExceptionResolver")
  public SimpleMappingExceptionResolver
                  createSimpleMappingExceptionResolver() {
    SimpleMappingExceptionResolver r =
                new SimpleMappingExceptionResolver();

    Properties mappings = new Properties();
    mappings.setProperty("DatabaseException", "databaseError");
    mappings.setProperty("InvalidCreditCardException", "creditCardError");

    r.setExceptionMappings(mappings);  // None by default
    r.setDefaultErrorView("error");    // No default
    r.setExceptionAttribute("ex");     // Default is "exception"
    r.setWarnLogCategory("example.MvcLogger");     // No default
    return r;
  }
  ...
}
```

这里最有用的可能就是`defaultErrorView`了，他可以用于定制默认的错误页面。

自己继承`SimpleMappingExceptionResolver`来扩展功能也是非常常见的

- 继承类可以在构造函数中设置好默认配置
- 覆盖`buildLogMessage`方法来自定义日志信息，默认返回固定的：Handler execution resulted in exception
- 覆盖`doResolveException`方法，可以向错误日志传入更多自己需要的信息

例子如下：

```java
public class MyMappingExceptionResolver extends SimpleMappingExceptionResolver {
  public MyMappingExceptionResolver() {
    // 默认启用日志
    setWarnLogCategory(MyMappingExceptionResolver.class.getName());
  }

  @Override
  public String buildLogMessage(Exception e, HttpServletRequest req) {
    return "MVC exception: " + e.getLocalizedMessage();
  }
    
  @Override
  protected ModelAndView doResolveException(HttpServletRequest req,
        HttpServletResponse resp, Object handler, Exception ex) {
    // 调用父类飞方法来获得ModelAndView
    ModelAndView mav = super.doResolveException(req, resp, handler, ex);
        
    // 添加额外的字段给视图
    mav.addObject("url", request.getRequestURL());
    return mav;
  }
}
```

## REST异常处理

REST风格下，返回的错误信息是一个json而不是一个页面，要如何做呢？特别简单，定义一个返回信息的类：

```java
public class ErrorInfo {
    public final String url;
    public final String ex;

    public ErrorInfo(String url, Exception ex) {
        this.url = url;
        this.ex = ex.getLocalizedMessage();
    }
}
```

然后在错误处理函数上加上`@ResponseBody`就行：

```java
@ResponseStatus(HttpStatus.BAD_REQUEST)
@ExceptionHandler(MyBadDataException.class)
@ResponseBody ErrorInfo
handleBadRequest(HttpServletRequest req, Exception ex) {
    return new ErrorInfo(req.getRequestURL(), ex);
}
```


## 什么时候用什么特效？

Spring给我们提供了很多选择，我们要如何选择呢？

- 如果异常是你自己声明的，可以考虑使用`@ResponseStatus`注解
- 其他的异常可以使用`@ControllerAdvice`中的`@ExceptionHandler`方法，或者用`SimpleMappingExceptionResolver`
- 如果Controller需要定制异常，可以在Controller中添加`@ExceptionHandler`方法。

如果你混用这几个特性，那要注意了，Controller中的`@ExceptionHandler`方法优先级比`@ControllerAdvice`中的`@ExceptionHandler`方法高，而如果有多个`@ControllerAdvice`类，那执行顺序是不确定的。


## 参考资料
- [Spring3.2新注解@ControllerAdvice - 开涛的博客—公众号：kaitao-1234567，一如既往的干货分享 - ITeye博客](http://jinnianshilongnian.iteye.com/blog/1866350)
- [Exception Handling in Spring MVC](https://spring.io/blog/2013/11/01/exception-handling-in-spring-mvc)