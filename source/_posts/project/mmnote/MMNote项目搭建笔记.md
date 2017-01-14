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












// todo
- electron-connect
- yarn
- squirrel



[使用yeoman创建项目生成器 | 木杉的博客]: http://mushanshitiancai.github.io/2017/01/09/js/tools/%E4%BD%BF%E7%94%A8yeoman%E5%88%9B%E5%BB%BA%E9%A1%B9%E7%9B%AE%E7%94%9F%E6%88%90%E5%99%A8/