---
title: 打包Electron应用
date: 2017-02-11 10:03:39
categories:
tags: [javascript,electron]
---

手动打包Electron比较繁琐，现在有两个自动打包Electron应用的工具：

- [electron-builder](https://github.com/electron-userland/electron-builder)
- [electron-packager](https://github.com/electron-userland/electron-packager)

自动打包工具会带来很多好处，他会自动帮你打包多个平台的安装包（windows/macos/linux），还会集成自动更新功能。这里我使用的是`electron-builder`。

<!--more-->

## Quick Start

安装：

```
npm i --save-dev electron-builder
```

确保你的`package.json`中包含这些字段：`name`, `description`, `version` and `author`。

在`pacpackage.json`中添加`build`属性：

```json
"build": {
  "appId": "your.id",
  "mac": {
    "category": "your.app.category.type"
  },
  "win": {
    "iconUrl": "(windows-only) https link to icon"
  }
}
```

全部的属性说明见[all options](https://github.com/electron-userland/electron-builder/wiki/Options)。

在项目根目录下建立`build`文件夹，其中存放三个图片：

1. background.png (macOS DMG background)
2. icon.icns (macOS app icon) 
3. icon.ico (Windows app icon) 

在`package.json`中添加两个script命令：

```json
"scripts": {
  "pack": "build --dir",
  "dist": "build"
}
```

然后运行`npm run dist`就行啦！默认会在项目目录的dist目录下生成可执行程序，安装包和zip包。比如我在mac上生成的例子：

```
.
├── github
│   └── latest-mac.json
└── mac
    ├── mmnote-1.0.0-mac.zip
    ├── mmnote-1.0.0.dmg
    └── mmnote.app
```

其中`github`目录是用于自动更新的。

## 定制

默认输出目录在`dist`。修改输出目录可以在`build`属性中添加配置：

```json
"directories": {
    "output": "package"
}
```

## asar格式

asar格式是Electron项目组推出的一种文件打包格式，官网介绍如下：

> Asar is a simple extensive archive format, it works like tar that concatenates all files together without compression, while having random access support.
> Asar是一个简单的可扩展的打包格式，类似于tar那样把所有文件不带压缩地打包到一个文件中，并且支持随机访问

支持随机访问是一个亮点吧，这样所谓Electron App的载体，传输更方便了，但是访问速度不会降低很多。

安装：

```
npm install -g asar
```

查看一个asar包中的文件：

```
asar list x.asar
```

### 在应用中访问asar

Electron应用中支持两种方式来访问asar：

1 Node APIs provided by Node.js 

Electron对nodejs做了一些补丁，所以像`fs.readFile`和`require`可以像访问普通目录一样访问asar文件。

```js
// 读取打包文件中的资源
const fs = require('fs')
fs.readFileSync('/path/to/example.asar/file.txt')
List all files under the root of the archive:

// 列出打包文件根目录下的文件
const fs = require('fs')
fs.readdirSync('/path/to/example.asar')

// 导入打包文件中的模块
require('/path/to/example.asar/dir/module.js')
You can also display a web page in an asar archive with BrowserWindow:

// 也可以使用asar中的页面初始化BrowserWindow
const {BrowserWindow} = require('electron')
let win = new BrowserWindow({width: 800, height: 600})
win.loadURL('file:///path/to/example.asar/static/index.html')
```

2 Web APIs provided by Chromium

在网页中可以使用file协议来访问asar中的文件：

```html
<script>
let $ = require('./jquery.min.js')
$.get('file:///path/to/example.asar/file.txt', (data) => {
  console.log(data)
})
</script>
```

## 参考资料
- [electron/application-distribution.md at master · electron/electron](https://github.com/electron/electron/blob/master/docs/tutorial/application-distribution.md)
- [electron-userland/electron-builder: A complete solution to package and build a ready for distribution Electron app with “auto update” support out of the box](https://github.com/electron-userland/electron-builder)

asar：

- [electron/asar: Simple extensive tar-like archive format with indexing](https://github.com/electron/asar)
- [Application Packaging - Electron](http://electron.atom.io/docs/tutorial/application-packaging/)