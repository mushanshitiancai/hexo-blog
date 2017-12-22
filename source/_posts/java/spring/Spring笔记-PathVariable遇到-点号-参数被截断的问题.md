---
title: Spring笔记-@PathVariable遇到.(点号)参数被截断的问题
date: 2017-12-21 18:14:41
categories: [Java,Spring]
tags: [java,spring]
---

在使用SpringMVC的`@PathVariable`注解的时候发现一个问题，就是如果参数中有.点号，那么参数会被截断。

<!--more-->

```java
@Controller
@RequestMapping("/example")
public class ExampleController {

    @RequestMapping("/{param}")
    public void test(@PathVariable("param") String param){
        System.out.println(param);
    }
}
```

对于不同的url，@PathVariable得到的参数为：

```
/example/test          => text
/example/test.ext      => text
/example/test.ext.ext2 => text.ext
```

可以看出路径参数中最后一个.以及之后的文本被截断了。

这个问题有两种结局方案：

**第一种方法**是在`@PathVariable`中指定参数的正则规则：

```java
@Controller
@RequestMapping("/example")
public class ExampleController {

    @RequestMapping("/{param:.+}")
    public void test(@PathVariable("param") String param){
        System.out.println(param);
    }
}
```

这样`param`参数批量的规则是`.+`，也就是一个或者一个以上的所有字符。这样Spring就不会截断参数了。

这个方法在Spring3/4中都适用，但不是一个完美的方法，因为你需要修改每一个使用`@PathVariable`的地方。

**第二种方法**是添加一个配置，指定让Spring不处理`@PathVariable`的点号：

```java
@Configuration
protected static class AllResources extends WebMvcConfigurerAdapter {
    @Override
    public void configurePathMatch(PathMatchConfigurer matcher) {
        matcher.setUseRegisteredSuffixPatternMatch(true);
    }
}
```

```xml
<mvc:annotation-driven>
    [...]
    <mvc:path-matching registered-suffixes-only="true"/>
</mvc:annotation-driven>
```

这个方法支持Spring4。


## 参考资料
- [Spring MVC – @PathVariable dot (.) get truncated](https://www.mkyong.com/spring-mvc/spring-mvc-pathvariable-dot-get-truncated/)
- [rest - Spring MVC @PathVariable with dot (.) is getting truncated - Stack Overflow](https://stackoverflow.com/questions/16332092/spring-mvc-pathvariable-with-dot-is-getting-truncated)