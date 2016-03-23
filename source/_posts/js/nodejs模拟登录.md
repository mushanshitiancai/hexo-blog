---
title: nodejs模拟登录
date: 2016-03-20 18:51:26
tags: [js,nodejs]
---

写个模型登录新浪微博练个手。

```
$ mkdir weibo-test
$ cd weibo-test
$ vi package.json

{
  "name": "weibo-demo",
  "version": "v0.0.1",
}

$ npm install superagent --save
```

## superagent的使用
superagent的官方文档简单明了：[SuperAgent - Ajax with less suck](http://visionmedia.github.io/superagent/)

## 服务端的jQuery-cheerio

- [cheerio](https://www.npmjs.com/package/cheerio)
- [通读cheerio API - CNode技术社区](https://cnodejs.org/topic/5203a71844e76d216a727d2e)

## 参考资料
- [node.js实现模拟登录，自动签到领流量。 - CNode技术社区](https://cnodejs.org/topic/54e96cf7ddce2d471403203f)
- [记一次用 NodeJs 实现模拟登录的思路 - 网道 - SegmentFault](https://segmentfault.com/a/1190000003851057)
