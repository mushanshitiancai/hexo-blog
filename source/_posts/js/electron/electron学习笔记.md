---
title: electron学习笔记
date: 2016-12-08 22:41:07
categories:
tags: [javascript,electron]
---

Electron是github推出的用HTML5技术开写桌面应用的一个框架，感觉已经成为开发桌面应用的首选了。

## 入门
我们可以通过官方提供的一个quick start程序来了解一个electron程序时怎么样的。

```
# Clone the Quick Start repository
$ git clone https://github.com/electron/electron-quick-start

# Go into the repository
$ cd electron-quick-start

# Install the dependencies and run
$ npm install && npm start
```

运行就可以看到程序启动了。虽然是一个普通程序的外观，但是里面显示的Chrome开发者工具让人一下就明白了这其实是一个Chrome浏览器。Electron的本质就是Chrome前端加上node执行器。

Electron是如何执行代码的呢？我们可以看electron-quick-start里面的main.js，这个就是程序的入口文件。Electron本体在启动后，就会查找执行路径下的main.js，并载入执行。

```
const electron = require('electron')
// 控制程序生命周期的模块
const app = electron.app
// 用于创建浏览器窗口的模块
const BrowserWindow = electron.BrowserWindow

const path = require('path')
const url = require('url')

// 持有window对象的全局引用，如果你不这么做，那么在javascript执行垃圾回收时，window就会被关闭了
let mainWindow

function createWindow () {
  // 创建一个浏览器窗口
  mainWindow = new BrowserWindow({width: 800, height: 600})

  // 指定浏览器加载index.html这个文件
  mainWindow.loadURL(url.format({
    pathname: path.join(__dirname, 'index.html'),
    protocol: 'file:',
    slashes: true
  }))

  // 指定浏览器打开DevTools
  mainWindow.webContents.openDevTools()

  // 当窗口被关闭时会触发closed事件
  mainWindow.on('closed', function () {
	// 解除window对象的引用
    mainWindow = null
  })
}

// 当Electron启动完毕，可以新建浏览器窗口是会触发ready事件
app.on('ready', createWindow)

// 当所有窗口都关闭是会触发window-all-closed事件
app.on('window-all-closed', function () {
  // OS X比较特殊，窗口关闭并不会退出程序，除非指定退出或者执行Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', function () {
  // 在OS X中，点击dock上的图标是，如果这个程序没有窗口了，一般会再次新建一个
  if (mainWindow === null) {
    createWindow()
  }
})
```

看了整个main.js，发现还是很简单的。程序可以没有界面，如果有界面的话就是在main.js中新建的浏览器窗口。

