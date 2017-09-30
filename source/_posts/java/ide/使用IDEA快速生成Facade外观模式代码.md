---
title: 使用IDEA快速生成Facade外观模式代码
date: 2016-06-14 11:36:43
categories: [Java]
tags: java
---

最近在读《How Tomcat Works》，其中讲到了，直接将内部的Request类传给Servlet是不好的。因为知道内部实现的人，会在Servlet中吧ServletRequest向下转型为具体的实现类，然后调用实现类的具体方法。

这样是不好的，因为如果用户可以直接操作实现类，那么就不是面向对象编程了，而且实现类的升级会受到很大限制。

为了解决这个问题，可以使用Facade模式，建立一个RequestFacade类，作为包装，传给用户的是Facade类，这样用户就无法直接操作Request类了。

代码类似如下：

```
public class HttpRequestFacade implements HttpServletRequest{
    public HttpServletRequest request;

    HttpRequestFacade(HttpServletRequest request){ //传入具体的实现类
        this.request = request;
    }

    public String getAuthType() {
        return request.getAuthType();
    }

    public Cookie[] getCookies() {
        return request.getCookies();
    }
    ...
}
```

这会涉及到很多重复的代码，这时候我总是会想到偷懒。。。IDE可以帮我们自动生成么？

IDEA是可以的。

```
public class HttpRequestFacade implements HttpServletRequest{
    public HttpServletRequest request;
}
```

然后选择Code-Delegate Methods，然后选择request这个field，然后生成，就OK啦！

Java虽然啰嗦，但是配合IDE的功能，还是弥补了不少。

## 参考资料
- [JAVA设计模式十九--Facade(外观模式) - hfmbook的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/hfmbook/article/details/7702642)
- [java - Generate Code with redirection IntelliJ Idea 15 - Stack Overflow](http://stackoverflow.com/questions/35635834/generate-code-with-redirection-intellij-idea-15)
- [java - Can IntelliJ automatically create a decorator class? - Stack Overflow](http://stackoverflow.com/questions/4325699/can-intellij-automatically-create-a-decorator-class)