---
title: vscode使用笔记
date: 2017-01-07 18:25:24
categories:
tags:
---

推荐在使用vscode中的一些技巧和插件。

![](https://code.visualstudio.com/home/home-screenshot-mac-lg-2x.png)

<!--more-->

## 插件

### Markdown相关
实话说，目前vscode写markdown的体验并不好。插件也很一般。

- Paste Image 我自己写的插件，用于从剪贴板粘贴图片
- Markdown Navigate 打开符号列表时会显示markdown的标题，可以导航
- Markdown Shortcuts 添加了编写markdown常用的快捷键，新建table的功能不错
- Markdown Helper 也是编写markdown的常用快捷键，包含了格式化功能

## 调试

vscode一个牛逼之处就是内置了完善的调试支持。

[node-debug tutorial](http://i5ting.github.io/node-debug-tutorial/)


调试gulp：

```json
{
    "name": "Launch gulp-test2",
    "type": "node2",
    "request": "launch",
    "program": "${workspaceRoot}/node_modules/gulp/bin/gulp.js",
    "cwd": "${workspaceRoot}",
    "outFiles": ["./test-out/**/*.js"],
    "sourceMaps": true,
    "args":[
        "test"
    ]
}
```