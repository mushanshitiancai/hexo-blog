---
title: Spring中获取被代理的真实类
date: 2017-03-13 17:02:03
categories: [Java,Spring]
tags: [java,spring]
---

对一个Autowired进来的类调用getClass，发现得到的类是:"com.xxx.search.provider.service.SearchServiceImpl$$EnhancerBySpringCGLIB$$129db519"，一看就不是正经类。从名字中可以看出，这个是被代理后的类，可能因为这个类被AOP了吧。但是我在反射操作是需要原始的类的信息，要如何得到呢？

<!--more-->

`org.springframework.aop`下有一个很重要的接口：`TargetClassAware`，这个接口表示目前这个类是被代理的。所以我们可以通过判断一个实例是否是`TargetClassAware`的实例来判断他是否是一个代理类。而且`TargetClassAware`接口提供了`getTargetClass`方法来获取真实类。可以这么用：

```java
if(aInstance instanceof TargetClassAware){
    aInstance.getTargetClass();
}
```

不过更推荐的做法是使用`org.springframework.aop.support.AopUtils`提供的`getTargetClass`方法来获取真实类。可以看看其源码：

```java
public static Class<?> getTargetClass(Object candidate) {
    Assert.notNull(candidate, "Candidate object must not be null");
    Class result = null;
    if(candidate instanceof TargetClassAware) {
        result = ((TargetClassAware)candidate).getTargetClass();
    }

    if(result == null) {
        result = isCglibProxy(candidate)?candidate.getClass().getSuperclass():candidate.getClass();
    }

    return result;
}
```

代码首先判断当前类是否是`TargetClassAware`的实现，如果是，调用`getTargetClass`，方法还判断当前类是否是CglibProxy，如果是基于cglib的代理类，因为是基于继承来实现代理，所以获取父类就是真实类了。

## 参考资料
- [java - Obtain real Class object for Spring bean - Stack Overflow](http://stackoverflow.com/questions/2289211/obtain-real-class-object-for-spring-bean)
- [AopUtils](http://docs.spring.io/spring/docs/3.0.x/javadoc-api/org/springframework/aop/support/AopUtils.html#getTargetClass(java.lang.Object))