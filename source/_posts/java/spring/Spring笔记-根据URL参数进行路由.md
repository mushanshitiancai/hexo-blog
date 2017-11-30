---
title: Spring笔记-根据URL参数进行路由
date: 2017-11-30 17:30:44
categories: [Java,Spring]
tags: [java,spring]
---

在写接口的时候发现一个问题，就是两个REST接口的URL的path部分是一样的，根据query传入不同的参数来区分。

比如S3普通上传接口是是：

```
PUT /{bucketname}/{ objectname}
```

分块上传的接口是：

```
PUT /{bucketname}/{objectname}?partNumber={partNumber}&uploadId={uploadId} 
```

传入`partNumber`和`uploadId`是一个接口，没有传入这两个参数是另外一个接口，那Spring中要如何进行路由设置呢？

<!--more-->

一般我们设置路由都是`@RequestMapping(value = "/xx", method = RequestMethod.GET)`。然后在方法签名中可以通过`@RequestParam`注入参数。

但是直接通过注入不同的参数来实现区分是不行的，比如：

```java
@ResponseBody
@RequestMapping(value = "/xx", method = RequestMethod.GET)
public String get1(){
    return "get1";
}

@ResponseBody
@RequestMapping(value = "/xx", method = RequestMethod.GET)
public String get2(@RequestParam name){
    return "get2" + name;
}
```

这样会报错：

```
java.lang.IllegalStateException: Ambiguous mapping. Cannot map 'DemoController_v01' method 
public java.lang.String com.nd.sdp.ndss.controller.v01.DemoController.get1()
to {[/demo/xx],methods=[GET]}: There is already 'DemoController_v01' bean method
```

意思是重复注册了，所以`@RequestParam`是不能用来作为路由依据的。

`@RequestMapping`作为路由注解，除了常用的`value`字段用于设置url外，还提供了`params`参数，可以指定如何匹配url中query的参数。又几种配置方法：

- `myParam=myValue`匹配有myParam参数，并且等于myValue的url
- `myParam!=myValue`匹配有myParam参数，并且不等于myValue的url
- `myParam`匹配有myParam参数的url
- `!myParam`匹配没有myParam参数的url

这样就可以很灵活的指定路由了。

而且`@RequestMapping`还提供了`headers`参数，可以让我们根据Header的情况进行路由！