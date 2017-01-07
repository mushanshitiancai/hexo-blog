---
title: electron学习笔记
date: 2016-12-08 22:41:07
updated: 2017-01-07 12:09:24
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

## 菜单
菜单是应用程序必不可少的元素。在不同的系统上，菜单的表现也完全不同。Windows和Linux中，菜单是显示在应用程序窗口上的，而Mac中，菜单则是固定在桌面上方。Electron支持所有的这些菜单，但是针对特定系统，你可能需要一点特定代码来获取最好的适配。

创建菜单有两种方式：

```
const {app, Menu, MenuItem } = require('electron')

// 按照对象的方式来构建菜单对象
const menu = new Menu()
menu.append(new MenuItem({label: 'MenuItem1', click() { console.log('item 1 clicked') }}))
menu.append(new MenuItem({type: 'separator'}))
menu.append(new MenuItem({label: 'MenuItem2', type: 'checkbox', checked: true}))

// 使用json模板来构建菜单。模板数组中的每个对象都是用于构建MenuItem传入的参数。
const template = [
  {
    label: 'Edit',
    submenu: [
      {
        role: 'undo'
      },
      {
        role: 'redo'
      }
    ]
  },
  {
    role: 'help',
    submenu: [
      {
        label: 'Learn More',
        click () { require('electron').shell.openExternal('http://electron.atom.io') }
      }
    ]
  }
]
const menu = Menu.buildFromTemplate(template)
Menu.setApplicationMenu(menu)
```

应用程序中存在两种菜单。

- 应用程序菜单
- 上下文菜单

程序程序菜单是程序级别的菜单，而上下文菜单则是在应用内部点击右键显示的菜单。对应的api为：

```
// 设置应用程序菜单
const menu = Menu.buildFromTemplate(template)
Menu.setApplicationMenu(menu)

// 设置上下文菜单
window.addEventListener('contextmenu', (e) => {
  e.preventDefault()
  menu.popup(remote.getCurrentWindow())
}, false)
```

知道怎么创建显示后，我们再来看看菜单项MenuItem构造函数中的详细设置：

```
click       Function      菜单项被点击时触发的回调函数，参数为(menuItem, browserWindow, event)
role        String        定义菜单项的操作，如果指定，则无视click属性
type        String        可选值有：normal, separator, submenu, checkbox 和 radio
label       String        菜单项的标题
sublabel    String        菜单项的子标题
accelerator Accelerator   
icon        (NativeImage | String) 菜单项的图标
enabled     Boolean       如果为false，则菜单项会变灰，不可点击
visible     Boolean       如果为false，这菜单项会不可见
checked     Boolean       指定菜单项是否被选中，只有type为checkbox或者radio的才有效
submenu     (MenuItemConstructorOptions[] | Menu) 设置子菜单
id          String        唯一标示一个菜单。position属性可以使用id来指定位置
position    String        可以细粒度的定义当前菜单项在菜单中的位置
```

其中，role字段非常非常重要，最好每个菜单项都设置上。


## IPC
关于ipc。一般应用于主进程与渲染进程间通信。比如用户点击了菜单，主进程得到通知，然后再通过ipc通知渲染进程。

```
// render进程
const {ipcRenderer} = require('electron')

// 发送同步信息，直接获取结果
console.log(ipcRenderer.sendSync('synchronous-message', 'ping')) // prints "pong"

// 异步的话，发送和获取结果需要在两个地方处理
ipcRenderer.send('asynchronous-message', 'ping')

ipcRenderer.on('asynchronous-reply', (event, arg) => {
  console.log(arg) // prints "pong"
})
```

```
// 主进程
const {ipcMain} = require('electron')

// 处理同步信息，返回值使用event.returnValue = ？
ipcMain.on('synchronous-message', (event, arg) => {
  console.log(arg)  // prints "ping"
  event.returnValue = 'pong'
})

// 处理异步信息，使用event.sender.send发送返回值
ipcMain.on('asynchronous-message', (event, arg) => {
  console.log(arg)  // prints "ping"
  event.sender.send('asynchronous-reply', 'pong')
})
```

也可以主进程给渲染进程发送，使用`webContents.send`。

## 注册全局快捷键
全局快捷键是系统机械的，就算程序不在前台，也会快捷键也会触发。必须在app的ready实践之后使用。

```
const {app, globalShortcut} = require('electron')

app.on('ready', () => {
  // 注册快捷键'CommandOrControl+X'
  const ret = globalShortcut.register('CommandOrControl+X', () => {
    console.log('CommandOrControl+X is pressed')
  })

  // 判断注册是否成功
  if (!ret) {
    console.log('registration failed')
  }

  // 检查快捷键是否被注册
  console.log(globalShortcut.isRegistered('CommandOrControl+X'))
})

app.on('will-quit', () => {
  // 取消注册
  globalShortcut.unregister('CommandOrControl+X')

  // 取消全部注册
  globalShortcut.unregisterAll()
})
```

**快捷键定义**语法在这里有说明：[Accelerator - Electron](http://electron.atom.io/docs/api/accelerator/)


## 打包

- [electron-userland/electron-packager: Package and distribute your Electron app with OS-specific bundles (.app, .exe etc) via JS or CLI](https://github.com/electron-userland/electron-packager)
- [electron-userland/electron-builder: A complete solution to package and build a ready for distribution Electron app with “auto update” support out of the box](https://github.com/electron-userland/electron-builder)

## 参考资料
- [使用 Electron 构建桌面应用 - 前端外刊评论 - 知乎专栏](https://zhuanlan.zhihu.com/p/20225295?columnSlug=FrontendMagazine)
