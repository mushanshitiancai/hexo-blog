---
title: Servlet3笔记-文件上传
date: 2017-06-14 10:41:06
categories: [Java]
tags: [java,servlet]
---

在Servlet3.0以前，处理文件上传是非常痛苦的，网上查资料可以看到处理上传文件需要一百多行代码，而且是在依赖了第三方库的情况下。Servlet3.0添加了文件上传的原生支持，可以很简单的处理文件上传。

<!-- more -->

Servlet3.0升级了`HttpServletRequest`类，添加了两个方法：

- `Collection<Part> getParts()`
- `Part getPart(String name)`

这两个方法可以获取请求中的part，也就是格式为`multipart/form-data`的POST中的part。通过Part类的`getSubmittedFileName`，`getInputStream`方法，可以很简单的得到上传文件的名称和输入流。

但是默认Servlet不会去处理请求体重的part数据。需要在Servlet上添加`@MultipartConfig`注解才会开启这个特性。

## 参考资料
- [Servlet3.0学习总结(三)——基于Servlet3.0的文件上传 - 紫竹星云 - 博客频道 - CSDN.NET](http://blog.csdn.net/estelle_belle/article/details/51751844)