---
title: MMNote项目搭建笔记
date: 2016-12-30 07:55:56
categories:
tags: [mmnote]
---

MMNote是我正在做的一款基于Electron平台的Markdown编辑器。我想让他基于时下最新的前端技术，TypeScript，Webpack，React，Redux等。我是Java出生，我发现现在前端搭建一个项目可不比搭建以后Java后端项目来得简单，或者实话说，更难。因为发展得太快，新设计，新库层出不穷，所以方案特别多，很可能现在的最优方案过一阵子就被人抛弃了，这是好事，也是坏事。比如Atom基于CoffeeScript构建，而CoffeeScript在风光几年后因为ES6的退出迅速没落，而还要称霸21世纪的Atom就尴尬了。

因为我也是初学前端客户端开发，所以想要渐进式的把所学融入到这个项目中，项目搭建也是，一开始会很简单（但我也花了好几周。。），为了快速上周，在开发过程中，我们再来一步步升级项目结构。

## 初始版本
2017年01月09日

虽然是初始版本，但是其实已经比较完善了。

- electron 1.4.13
- 语言：typescript 2.1.4，less 2.7.1
- 打包：webpack 1.14.0
- 视图框架：react 15.4.1
- 编辑器：codemirror 5.21.0
- css初始化：normalize.css 5.0.0

webpack需要的依赖：

- loader：awesome-typescript-loader less-loader source-map-loader  css-loader style-loader
- 调试服务器：webpack-dev-server

我写了一个初始化的脚本文件，这样就算老是折腾也不怕。

```
#!/bin/sh

if [[ -d mmnote ]]; then
    echo "mmnote folder alerdy existed."
    exit
fi

mkdir mmnote
cd mmnote
npm init -y

npm install --save-dev webpack typescript awesome-typescript-loader less  source-map-loader  css-loader style-loader webpack-dev-server 
npm install --save react react-dom @types/react @types/react-dom lodash electron normalize.css
npm install --save codemirror @types/codemirror react-split-pane @types/react-split-pane
```

目录结构：

```
.
├── app
│   ├── index.html
│   ├── main.js
│   └── package.json
├── src
│   ├── component
│   │   ├── app.less
│   │   └── app.tsx
│   └── index.tsx
├── package.json
├── tsconfig.json
└── webpack.config.js
```

## 使用yeoman
2017年01月14日

一开始我还打算写个shell脚本来新建项目，这样以后再推翻迭代时建立项目会简单一些。后来我了解到了yeoman这个项目生成器工具，所以打算用yeoman来做一个生成“electron-typescript-react”的生成器。yeoman的教程可以看[使用yeoman创建项目生成器 | 木杉的博客][使用yeoman创建项目生成器 | 木杉的博客]

// TODO


## 关于调试
调试开发分为两部分，一个是代码更新自动重启，一个是断点调试。

代码更新重启，这个会极大方便开发。使用webpack-dev-server可以自动刷新render代码。但是主线程的代码更新就无能为力了。

[electron-connect](https://github.com/Quramy/electron-connect)这个项目支持restart和reload electron。restart就是当主进程代码变化时，重启electron。reload是当render代码变化时，让electron重新加载当前页面。

```
npm install electron-connect --save-dev
```

结合gulp使用：

```js
'use strict';

var gulp = require('gulp');
var electron = require('electron-connect').server.create();

gulp.task('serve', function () {

  // Start browser process
  electron.start();

  // Restart browser process
  gulp.watch('app.js', electron.restart);

  // Reload renderer process
  gulp.watch(['index.js', 'index.html'], electron.reload);
});
```

然后在electron代码中植入：

```js
'use strict';

var app = require('app');
var BrowserWindow = require('browser-window');
var client = require('electron-connect').client;

app.on('ready', function () {
  var mainWindow = new BrowserWindow({
    width: 400,
    height: 300
  });
  mainWindow.loadUrl('file://' + __dirname + '/index.html');

  // Connect to server process
  client.create(mainWindow);
});
```

### 2017年01月20日 星期五 菜单

如果不给应用添加复制粘贴的菜单项目，electron中的调试控制台也是不能复制粘贴的。

使用原生webpack替代webpack-stream。因为后者在watch模式下有时候会出现没有更新代码的情况。

实现保存功能，然后我就发现我举步维艰了。React中，子控件如果有事件发生，可以使用onXX回调通知父控件。那如果父控件需要通知子控件做一些操作，要如何做？？

通过props传入数据的确是可以更新子控件，但是如果是事件呢？比如我要通知Editor子控件保存当前文件，感觉不能用props来做。









// todo
- electron-connect
- yarn
- squirrel
- [usage with gulp](https://webpack.github.io/docs/usage-with-gulp.html)

[gulp + webpack 构建多页面前端项目 - OPEN资讯](http://www.open-open.com/news/view/1c51682)
[webpack&gulp集成简介 - 简书](http://www.jianshu.com/p/8c9c8f5649c9)

[使用yeoman创建项目生成器 | 木杉的博客]: http://mushanshitiancai.github.io/2017/01/09/js/tools/%E4%BD%BF%E7%94%A8yeoman%E5%88%9B%E5%BB%BA%E9%A1%B9%E7%9B%AE%E7%94%9F%E6%88%90%E5%99%A8/