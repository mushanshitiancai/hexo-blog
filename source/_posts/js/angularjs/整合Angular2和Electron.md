---
title: 整合Angular2和Electron
date: 2016-12-11 21:11:42
categories:
tags: [js,angularjs,electron]
---

Electron不限制使用什么前端技术，所以我们可以在其中使用任何我们喜欢的框架。现在我们来研究一下如何吧Angular程序部署到Electron中。

<!-- more -->

## 工程搭建

新建一个Angular工程可不是一个简单的事情，一个完整Angular工程设计到很多技术，比如打包方式，如何安排自动化测试等。现在比较好的做法有两个：

1. 使用Angular官方提供的[Angular CLI][angular-cli]来新建工程。
2. 使用社区维护的[angular2-webpack-starter][angular2-webpack-starter]项目。

这两种做法都会生成一个完整的，整合了目前最佳实践的Angular模板项目。在这里我选择Angular CLI，但是这个项目目前还处于早期开发中。

首先使用CLI新建工程：

```
ng new electron-angular-test
```

然后需要在这个项目中安装electron依赖，这样才能electron命令来启动Electron来运行项目：

```
cd electron-angular-test
npm install --save-dev electron
```

默认Angular CLI会在项目目录下建立一个src目录用于存放项目代码。我们这里新建一个专门安放Electron启动代码的目录：

```
mkdir src/electron
```

一个Electron项目，也需要一个package.json，这个package.json的结构和npm的package.json很像，Electron启动器在启动时会加载这个文件。

```
// src/electron/package.json

{
    "name": "angular-electron",
    "version":  "0.0.1",
    "main": "electron.js"
}
```

配置中的main字段指定了这个Electron应用的入口文件是哪个文件。我们来新建这个文件：

```
// src/electron/electron.js

const {app, BrowserWindow} = require('electron')
const path = require('path')
const url = require('url')

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let win

function createWindow () {
  // Create the browser window.
  win = new BrowserWindow({width: 800, height: 600})

  // and load the index.html of the app.
  win.loadURL(url.format({
    pathname: path.join(__dirname, 'index.html'),
    protocol: 'file:',
    slashes: true
  }))

  // Open the DevTools.
  win.webContents.openDevTools()

  // Emitted when the window is closed.
  win.on('closed', () => {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    win = null
  })
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow)

// Quit when all windows are closed.
app.on('window-all-closed', () => {
  // On macOS it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  // On macOS it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (win === null) {
    createWindow()
  }
})

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.
```

这里需要**注意**一下，我们需要修改`src/index.html`，把

```
<base href="/">
```

改为：

```
<base href="./">
```

这是因为Angular CLI建立的工程默认是基于`http://`协议的，而Electron加载应用的时候，使用的是`file://`协议。

最后我们需要在npm script中添加用于从electron启动应用的命令：

```
"build-electron": "ng build && cp src/electron/* dist/",
"electron": "npm run build-electron && electron dist/",
```

这样我们执行`npm run electron`就能启动应用了。

## 问题
现在虽然可以启动应用了，但是有几个问题：

- 修改代码electron中的程序无法自动刷新，而在浏览器中运行程序会自动刷新，这个对于开发的帮助很大，要如何配置？
- 我在Component代码中执行`console.log(process.platform);`，得到的输出竟然是undefined！这是为什么？
- 启动应用后，Loading大致花了半秒钟，这是Angular最短启动时间了么？

## 解决问题
### 在Electron中开发如何自动刷新？
这个问题目前有两个思路

1. 使用`ng build --watch`命令监视代码变化，一旦代码发生变化就重新编译。和浏览器调试的区别在于需要手动刷新Electron。
2. 在electron.js中，默认在窗口载入页面的代码是：

	```
    win.loadURL(url.format({
      pathname: path.join(__dirname, 'index.html'),
      protocol: 'file:',
      slashes: true
    }))
	```
	
	这是基于`file://`协议的，我们可以直接把这行修改为：
	
	```
	win.loadURL("http://localhost:4200/");
	```
	
	就和浏览器调试一模一样了！区别在于使用的是Electron运行环境！这个方法目前看起来最好，但是不知道有没有什么坑。
	
### 如何在Angular代码中使用node模块？
TODO

[add webpack target configuration via angular-cli.json by vilarone · Pull Request #3346 · angular/angular-cli](https://github.com/angular/angular-cli/pull/3346)
[Problems importing native modules (for Electron app) · Issue #3482 · angular/angular-cli](https://github.com/angular/angular-cli/issues/3482)
[Problems importing native modules (for Electron app) · Issue #3482 · angular/angular-cli](https://github.com/angular/angular-cli/issues/3482)

## 参考资料
- [Package an Angular CLI Application into Electron | Bruno d'Auria](http://www.blog.bdauria.com/?p=806)


[angular-cli]: https://github.com/angular/angular-cli
[angular2-webpack-starter](https://github.com/AngularClass/angular2-webpack-starter)