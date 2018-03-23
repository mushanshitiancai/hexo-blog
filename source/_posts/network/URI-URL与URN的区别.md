---
title: 'URI,URL与URN的区别'
date: 2018-03-23 17:27:46
categories:
tags: [http]
---

URI：统一资源标识符 Uniform Resource Identifier
URL：统一资源定位符 Uniform Resource Locator
URN：统一资源名称 Uniform Resource Name

URI通过标识符的方式确定一个资源。
URL通过定位的方式确定一个资源。
URN通过名称的方式确定一个资源。
URL和URN是URL的子集。URI可以是URL，URN或者两者都是。

比如对应人这个资源，用URL的方式表示的话可能是：人类住址协议://地球/中国/福建省/福州市/xxx/马志彬.人。
而用URN的表示方式则可用身份证号来唯一确定。
而这两种方式都是URI。

![](https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/URI_Euler_Diagram_no_lone_URIs.svg/320px-URI_Euler_Diagram_no_lone_URIs.svg.png)

URI的格式为`URI协议名:内容`。
通用的URI格式为：`scheme:[//[user[:password]@]host[:port]][/path][?query][#fragment]`
URN使用`urn`作为协议名。 

## 参考资料
- [统一资源标志符 - 维基百科，自由的百科全书](https://zh.wikipedia.org/wiki/%E7%BB%9F%E4%B8%80%E8%B5%84%E6%BA%90%E6%A0%87%E5%BF%97%E7%AC%A6)
- [统一资源定位符 - 维基百科，自由的百科全书](https://zh.wikipedia.org/wiki/%E7%BB%9F%E4%B8%80%E8%B5%84%E6%BA%90%E5%AE%9A%E4%BD%8D%E7%AC%A6)
- [统一资源名称 - 维基百科，自由的百科全书](https://zh.wikipedia.org/wiki/%E7%BB%9F%E4%B8%80%E8%B5%84%E6%BA%90%E5%90%8D%E7%A7%B0)
- [分清 URI、URL 和 URN](http://www.ibm.com/developerworks/cn/xml/x-urlni.html)
- [HTTP 协议中 URI 和 URL 有什么区别？](https://www.zhihu.com/question/21950864)
- [http - What is the difference between a URI, a URL and a URN? - Stack Overflow](https://stackoverflow.com/questions/176264/what-is-the-difference-between-a-uri-a-url-and-a-urn)
- [URIs, URLs, and URNs: Clarifications and Recommendations 1.0](https://www.w3.org/TR/uri-clarification/)