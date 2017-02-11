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

## 参考资料
- [electron/application-distribution.md at master · electron/electron](https://github.com/electron/electron/blob/master/docs/tutorial/application-distribution.md)
- [electron-userland/electron-builder: A complete solution to package and build a ready for distribution Electron app with “auto update” support out of the box](https://github.com/electron-userland/electron-builder)