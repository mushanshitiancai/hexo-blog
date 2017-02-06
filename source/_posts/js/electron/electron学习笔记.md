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
// Clone the Quick Start repository
$ git clone https://github.com/electron/electron-quick-start

// Go into the repository
$ cd electron-quick-start

// Install the dependencies and run
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

我们来学习Electron提供的各种API吧。完整的列表可以参考[API Reference - Electron](http://electron.atom.io/docs/api/)。

Electron的API分为三类，一类是只能在主进程调用的，一类是只能在渲染进程调用的，一类是两边都能调用的。

## 对话框（dialog）
[dialog - Electron](http://electron.atom.io/docs/api/dialog/)

electron中展示一个对话框是非常简单的。例子：

```
const {dialog} = require('electron')
console.log(dialog.showOpenDialog({properties: ['openFile', 'openDirectory', 'multiSelections']}))
```

如果想要在render进程中使用，需要使用remote：

```
const {dialog} = require('electron').remote
console.log(dialog)
```

electron可以显示几种不同类型的对话框：

- dialog.showOpenDialog 打开对话框
- dialog.showSaveDialog 保存对话框
- dialog.showMessageBox 消息对话框
- dialog.showErrorBox   错误对话框

分别来看看如何使用。

**打开对话框**

```
dialog.showOpenDialog([browserWindow, ]options[, callback])

参数：
- browserWindow 可选 指定对话框模态显示在哪个窗口上
- options 对话框选项
  - title String - 标题
  - defaultPath String - 默认展示路径
  - buttonLabel String - 确定按钮的标题，不设置则使用默认的
  - filters FileFilter[] - 展示的文件过滤器
  - properties String[] - 设置对话框的属性，可以包含openFile(打开文件), openDirectory(打开目录), multiSelections(支持多选), createDirectory(支持创建目录) 和 showHiddenFiles(显示隐藏文件)
- callback Function (optional)
  - filePaths String[] - 回调函数的参数是用户选择的文件路径数组

返回值：
如果没有提供callback参数，那么showOpenDialog直接返回filePaths数组，即为同步调用方式。如果提供callback，则为异步调用方式。
```

filters字段的例子：

```
{
  filters: [
    {name: 'Images', extensions: ['jpg', 'png', 'gif']},
    {name: 'Movies', extensions: ['mkv', 'avi', 'mp4']},
    {name: 'Custom File Type', extensions: ['as']},
    {name: 'All Files', extensions: ['*']}
  ]
}
```

**注意**一点，在windows和linux上，打开对话框不能同时是文件对话框也是目录对话框，所以如果同时指定了`['openFile', 'openDirectory']`，将会显示一个目录对话框。

**保存对话框**

```
dialog.showSaveDialog([browserWindow, ]options[, callback])

参数：
- browserWindow BrowserWindow - 指定模态显示在哪个窗口上
- options Object
  - title String - 对话框标题
  - defaultPath String - 对话框默认打开路径
  - buttonLabel String - 确定按钮的标题，不设置则使用默认的
  - filters FileFilter[] - 展示的文件过滤器
- callback Function - 用户选择后的回调函数
  - filename String

返回值：
如果指定了callback参数，返回undefined，如果没有指定返回用户选择的路径。
```

**消息对话框**

```
dialog.showMessageBox([browserWindow, ]options[, callback])

参数：
- browserWindow BrowserWindow - 指定模态显示在哪个窗口上
- options Object
  - type String - 对话框类型，可以的取值有："none", "info", "error", "question" or "warning"。在Windows上, “question”和“info”是一样的, 除非你自定义图标
  - buttons String[] - 一个设置按钮标题的数组. 在Windows, 空数组表示只有一个OK按钮
  - defaultId Integer - 设置默认按钮对应的Index
  - title String - 对话框的标题，有些平台可能不显示
  - message String - 对话框的内容
  - detail String - 对话框的额外信息
  - icon NativeImage - 对话框的图标
  - cancelId Integer - 如果用户取消对话框而不是点击对话框中的按钮就会返回这个id。默认值是使用“cancel”或者“no”作为标题的按钮的Index，如果没有则是0。在macOS和Windows上，如果有“Cancel”按钮，则“Cancel”按钮的Index会覆盖cancelId的值。
  - noLink Boolean - windows特有。不用设置为true即可。
- callback Function
  - response Number - 返回点击的按钮的Index

返回值：
如果设置了callback，返回undefined，没有设置返回response。
```

对话框是模态的，会阻塞当前进程。

**错误对话框**

```
dialog.showErrorBox(title, content)

参数：
- title String - 标题
- content String - 内容
```

错误对话框可以在应用ready之前调用。一般使用来显示启动错误信息。

**注意**：如果指定了`browserWindow`参数，macOS会使用sheets风格来显示对话框。可以使用`BrowserWindow.getCurrentWindow().setSheetOffset(offset)`来设置sheets风格的偏移量。

## 菜单（Menu/MenuItem）
[Menu - Electron](http://electron.atom.io/docs/api/menu/)
[MenuItem - Electron](http://electron.atom.io/docs/api/menu-item/)

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
accelerator Accelerator   指定菜单对应的快捷键（具体见下文）
icon        (NativeImage | String) 菜单项的图标
enabled     Boolean       如果为false，则菜单项会变灰，不可点击
visible     Boolean       如果为false，这菜单项会不可见
checked     Boolean       指定菜单项是否被选中，只有type为checkbox或者radio的才有效
submenu     (MenuItemConstructorOptions[] | Menu) 设置子菜单
id          String        唯一标示一个菜单。position属性可以使用id来指定位置
position    String        可以细粒度的定义当前菜单项在菜单中的位置
```

关于菜单项定位，可以参考[Menu - menu-item-position](http://electron.atom.io/docs/api/menu/#menu-item-position)

其中，role字段非常非常重要，最好每个菜单项都设置上。role指定了这个菜单项目是干什么的。electron为我们定义好了许多通用的菜单项，比如复制，粘贴，重做这些。使用这些role，我们可以使用electron的自带实现，而且还可以有native体验。定义好的role有这些：

```
undo
redo
cut
copy
paste
pasteandmatchstyle
selectall
delete
minimize - Minimize current window
close - Close current window
quit- Quit the application
reload - Reload the current window
toggledevtools - Toggle developer tools in the current window
togglefullscreen- Toggle full screen mode on the current window
resetzoom - Reset the focused page’s zoom level to the original size
zoomin - Zoom in the focused page by 10%
zoomout - Zoom out the focused page by 10%
```

Mac的菜单有很多其平台特有的标准菜单项，这些使用这些role可以获得mac应用特有的体验：

```
about - Map to the orderFrontStandardAboutPanel action
hide - Map to the hide action
hideothers - Map to the hideOtherApplications action
unhide - Map to the unhideAllApplications action
startspeaking - Map to the startSpeaking action
stopspeaking - Map to the stopSpeaking action
front - Map to the arrangeInFront action
zoom - Map to the performZoom action
window - The submenu is a “Window” menu
help - The submenu is a “Help” menu
services - The submenu is a “Services” menu
```

当使用这些特有role时，options中只有`label`和`accelerator`这两个字段有效。

现在的一个问题是，对于一般的我们可以使用click来处理，那这些特殊role的，如何处理点击菜单的事件呢？

## 快捷键字符串（Accelerator）
[Accelerator - Electron](http://electron.atom.io/docs/api/accelerator/)

Accelerator是electron中对于快捷键字符串的称呼。使用的地方有MenuItem定义，`globalShortcut.register()`注册全局快捷键等。

例子如下：

```
CommandOrControl+A
CommandOrControl+Shift+Z
```

可用的修饰键有：

```
Command (or Cmd for short)
Control (or Ctrl for short)
CommandOrControl (or CmdOrCtrl for short)
Alt      （在mac中为Optional键）
Option
AltGr
Shift
Super    （在mac中为Command，在windows/Linux中为win键）
```

可用的按键代码有：

```
0 to 9
A to Z
F1 to F24
Punctuations like ~, !, @, #, $, etc.
Plus
Space
Tab
Backspace
Delete
Insert
Return (or Enter as alias)
Up, Down, Left and Right
Home and End
PageUp and PageDown
Escape (or Esc for short)
VolumeUp, VolumeDown and VolumeMute
MediaNextTrack, MediaPreviousTrack, MediaStop and MediaPlayPause
PrintScreen
```

## 注册全局快捷键（globalShortcut）
[globalShortcut - Electron](http://electron.atom.io/docs/api/global-shortcut/)

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

## 主进程和渲染进程间通信（ipcMain/ipcRenderer）
[ipcMain - Electron](http://electron.atom.io/docs/api/ipc-main/)
[ipcRenderer - Electron](http://electron.atom.io/docs/api/ipc-renderer/)

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

## 调用系统默认程序打开URL/文件（shell）
[shell - Electron](http://electron.atom.io/docs/api/shell/)

这个模块名字取得还是很令人迷惑的。主要用调用系统默认程序打开文件或者URL。

```
- 在默认文件管理器中打开路径        shell.showItemInFolder(fullPath)
- 使用对应的默认程序打开路径        shell.openItem(fullPath)
- 使用对应的默认程序打开URL        shell.openExternal(url[, options, callback])
- 移动路径对应的文件/文件夹到回收站  shell.moveItemToTrash(fullPath)
- 响铃 shell.beep()

windows特有：
- 创建快捷方式 shell.writeShortcutLink(shortcutPath[, operation], options)
- 读取快捷方式 shell.readShortcutLink(shortcutPath)
```

## 操作剪贴板
[clipboard - Electron](http://electron.atom.io/docs/api/clipboard/)

跨平台操作剪贴板本来是个很麻烦的事情的。但是electron包装的剪贴板模块简直易用到爆。

操作纯文本：

```
获取剪贴板文字 clipboard.readText([type])
往剪贴板写入文字 clipboard.writeText(text[, type])
```

操作图片：

```
获取剪贴板图片 clipboard.readImage([type])
返回NativeImage

往剪贴板写入图片 clipboard.writeImage(image[, type])
```

其他的还可以操作的格式有：HTML，RTF，Bookmark

## 使用vscode调试electron程序


## 打包

- [electron-userland/electron-packager: Package and distribute your Electron app with OS-specific bundles (.app, .exe etc) via JS or CLI](https://github.com/electron-userland/electron-packager)
- [electron-userland/electron-builder: A complete solution to package and build a ready for distribution Electron app with “auto update” support out of the box](https://github.com/electron-userland/electron-builder)

## 参考资料
- [使用 Electron 构建桌面应用 - 前端外刊评论 - 知乎专栏](https://zhuanlan.zhihu.com/p/20225295?columnSlug=FrontendMagazine)
- [Debugging Electron in Visual Studio Code](http://electron.rocks/debugging-electron-in-vs-code/)
