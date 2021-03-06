---
title: fir项目日志
date: 2016-01-23 15:23:37
tags: [project]
---

目的是实现一个笔记系统。一个与前端无关的笔记系统后端。

这里的前端指的是笔记软件。

那后端指的是什么呢？就像是`tern`，`ghc-mod`这样的语言后端。他们实现一个IDE所需要的功能，比如列出定义，跳到定义，重命名变量等。有了这样的后端，各个编辑器（emacs，vim，sublime等），在实现IDE功能时，直接调用后端就可以了。

该项目的起源是[atom-note](/2015/10/01/atom-note项目日志/)。

这里说一下atom。atom是github出品的新一代文本编辑器。其实就是一个浏览器。正是因为他就是一个浏览器，所以我觉得，他是现在这么多文本编辑器中的未来。所以我希望可以通过插件的形式，在atom上实现我想要的笔记软件。

但是随着设计的进展。我觉得把核心逻辑写在插件里头是不太好的，也就是所谓的感觉复用性不高。所以萌生了先实现后端的想法。

至于为什么叫`fir`，和飞儿乐队没有什么关系啦。是因为`Chinese fir`叫做杉木。

## 准备工作
目前我对于如何实现一个nodejs模块还所知甚少。所以还需要看不少代码学习一下。

- 看hexo-cli了解如何使用nodejs写命令行程序（因为fir后端至少要有命令行前端）
- 语言后端如何与前端交互，是前端调用后端的cli命令，还是通过网络协议调用？

### 自问自答
准备工作中的问题的答案，这里记录一下：
- 语言后端如何与前端交互，是前端调用后端的cli命令，还是通过网络协议调用？
  
  ghc-mod使用的是调用cli命令实现交互。([参考代码][ghcmod.py])
  tern使用的是server-client交互([参考文档][tern_server_doc])

  这两者各有利弊吧。我目前反正都要实现cli前端。而且与atom交互可以直接通过代码库方式引入。所以目前可以不需要考虑这个事情。

## 需求（不断添加中:D）

- 整合mermaid或者类似的纯文本图表工具

## 设计

- 使用百度脑图的思维导图开源组件

## 一步一步
### 2016年05月05日
今天查了atom和vscode的一些对比。

最感性的是这个视频对比：
[Atom vs Visual Studio Code - Memory and CPU - YouTube](https://www.youtube.com/watch?v=jBuizwplv1k&ab_channel=JoshuaWulf)

atom打开很慢，内存占用更是奇高。。。所以打算基于vscode开发。

[Microsoft/vscode: Visual Studio Code](https://github.com/Microsoft/vscode)


[ghcmod.py]: https://github.com/SublimeHaskell/SublimeHaskell/blob/e622d39d05c0f74b8ca9ae760b495bcf54828684/ghcmod.py
[tern_server_doc]: http://ternjs.net/doc/manual.html#server



