---
title: Postman技巧-互相依赖的请求实现链式调用
date: 2017-05-17 09:15:27
categories: [web]
tags: [web]
---

一个很常见的场景：业务请求需要session或者token，有专门的接口来获取session或者token。那么我们在测试业务接口的时候，就需要先调用getSession这样的接口，然后把session复制出来，放到业务请求的参数中，这个过程太痛苦了，有什么自动化的方法吗？

<!-- more -->

Postman作为强大的模拟请求工具，新版本中加入了脚本功能。通过在请求上绑定JavaScript代码片段，实现自动化测试！虽然这个功能时为了自动化测试而设计的，但是我们可以利用他提供的功能来刷新环境变量，供后续的请求使用。

在你的getSession请求的`Tests`标签页中添加代码：

```js
var jsonData = JSON.parse(responseBody);
postman.setEnvironmentVariable("session",jsonData.session);
```

这样在请求结束后，代码就会执行，其中的`responseBody`变量会被设置为请求返回的字符串。我们把其中的session字段取出来设置到环境变量中，然后你在请求其他业务代码就能使用到新的session啦！