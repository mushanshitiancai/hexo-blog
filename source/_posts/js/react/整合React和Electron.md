---
title: 整合React和Electron
date: 2016-12-13 23:23:53
categories:
tags: [js,react]
---

研究了几天的Angular2整合Electron后，我来研究React整合Electron了。。。我真的不是喜新厌旧之人，只是在一直在寻找趁手之物罢了。Angular2毕竟出来晚了，资料少，和Electron整合的资料更少，官方的CLI也表示近期不会支持的架势。加上搜索了一番Angular2的控件，发现少而且很多都是Angular1的控件，傻傻分不清楚。而搜了一波React的控件，好吧，的确质量都不错。

不过还是得说，Angular2是一个大而完整的框架，基于Typescript和围绕依赖注入我很喜欢。


[electron-react-boilerplate](https://github.com/chentsulin/electron-react-boilerplate)


## webpack配置注意事项
webpack配置需要注意的一点是，需要配置target为electron。如果不这么配置的话，webpack默认会编译为浏览器运行用的js。而如果你在js中require('fs')了，webpack会提示你找不到fs模块。而如果设置了目标为electron，因为electron运行页面中的js调用Node.js的包，所以webpack在遇到这种情况时，就忽略了。