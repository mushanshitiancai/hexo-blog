---
title: 【TODO】nodejs web栈
date: 2016-03-25 23:36:39
tags: [js,nodejs]
---

小的工具网站，原型啥的用nodejs来写还是很方便的。这里总结一下基于nodejs的web技术栈。方便日后开箱即用。

我不是前端，所以对nodejs没什么研究，这里使用的库基本都是npm上最火的库。因为js圈现在发展太快了，所以我觉得对于这些库也没必要深入研究，覆盖自己的需求即可。因为指不定那一天，新的库就来了。

- http框架：express
- 日志：winston
- mysql数据库：
- cookie：cookie-parser
- session：express-session

- 服务端处理dom：cheerio
- 网络请求库：unirest/superagent
- cookies：tough-cookie



## cookies

```


//序列化 反序列化
var o = cookieJar.serializeSync();
var cookieJar = CookieJar.deserializeSync();
```


[cheerio html 方法中文字体被转换问题，求教 - CNode技术社区](http://cnodejs.org/topic/54bdd639514ea9146862ac37)