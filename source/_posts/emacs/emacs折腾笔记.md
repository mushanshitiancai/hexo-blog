---
title: emacs折腾笔记
date: 2016-01-27 16:14:49
tags: [tools,emacs]
---

先扪心自问一下，为什么要花实现在emacs上。

第一种情况，因为有时候我需要在服务器端快速的编辑文件，或者处理那些小的代码仓库。如果再用samba等方法用本地IDE打开，还是比较麻烦的，所以希望可以用方法在服务器快速编辑一下。

第二种情况，我打算学习nginx，环境是用vagrant搭建的。所以我希望可以直接在虚拟机里看代码。目录共享然后本机本机也是可以，但是依然比较麻烦。

出于以上这两点，我对这个工具的要求是：
- 可以运行在terminal
- 可以使用鼠标点击，滚动（即使是在命令行中，我依然觉得鼠标是必须的）
- 具备IDE的基本功能（跳转，全局搜索）
- 具备项目的功能（项目内跳转，文件跳转）

我尝试了emacs的几个配置，最让我印象深刻的是spacemacs。他让emacs这个几十年的项目如此的惊艳！但是在终端中运行这个配置还是比较卡的，而且加上鼠标滚轮支持也卡得不行，终端中使用追求的就是速度，遂放弃。

我目前使用的插件中，最让我惊艳的是helm，他让emacs变得“好用”，而且通过和projectile，全局搜索，buffer搜索配合，使emacs的体验上升了好几个层面。

## 以daemon方式启动emacs
emacs被许多vim党嘲讽的地方就是如果插件安装多了启动速度会比较慢。emacs党的回击就是daemon模式。emacs的daemon模式就是以server启动在后台，然后client和server交互。所以client启动速度很快。

启动server：

    emacs --daemon

启动client：

    emacsclient -t    # 打开一个新的frame
    emacsclient -c    # 我不了解这两个的区别在哪里

关闭emacs server，在emacs中执行（M-x）：

    kill-emacs

## 使用帮助

查看快捷键搬说明：C-h k 然后按你想要查询的快捷键
查看当前模式所有可用的快捷键：C-h b

## emacs在终端中无法使用鼠标滚轮

```
(unless window-system
  (xterm-mouse-mode 1)
  (global-set-key [mouse-4] '(lambda ()
                               (interactive)
                               (scroll-down 1)))
  (global-set-key [mouse-5] '(lambda ()
                               (interactive)
                               (scroll-up 1))))
```

参考：[MouseTerm](https://bitheap.org/mouseterm/)

在prelude和spacemacs中，滚动都表现得非常的卡顿。这个让我非常苦恼。

原生的emacs是没有这个问题的，是什么插件导致的么？

## 关于难按的Ctrl
mac上的ctrl很不好按。突发奇想，把右边的command改成ctrl了（iTerm2中可以设置）。因为右边的command和option其实基本(100%)不用，所以留着也是浪费，还不如活用。

## 关闭音效

## 选区操作

## 搜索
C - s向下查找

C - r向上查找

按下C - s后输入要搜索的词，emacs会即时显示当前光标后第一个搜索到的结果，按C - s会跳到下一个结果，按C - r会跳到上一个结果。

按Enter结束查找或按C - g取消查找回到原来的地方。

按下C - s 或 C - r后，按M - p显示上一个搜索词，M - n显示下一个搜索词。类似C - p是上一行，C - n下一行。

按下C - s或 C - r后，输入要查找的词的头几个字，然后按C - w 会补全当前位置的单词。

[学习Emacs系列教程（八）：查找替换 - 下下签 - 博客园](http://www.cnblogs.com/robertzml/archive/2010/03/03/1675870.html)

## 替换


## 复制粘贴
C-w         剪切
M-w         复制

C-y           粘贴
M-y           在按下C-y后，按此键，切换粘贴的内容

//TODO 如何和系统剪贴板互访（这个在vi中很简单，在emacs中竟然没有现成解决方案）


## 窗口操作

快捷键：
| 按键 | 命令 | 操作 | 
| --- | --- | --- |
|C-x 0|delete-window|关闭窗口(emacs中成为delete)|
|C-x 1|delete-other-windows|关闭其他窗口|
|C-x o|other-window|切换到其他窗口|

## 【TODO】快捷键改进计划
C-q 这个按钮希望弄成保存并退出

C-q原本的用处：
(quoted-insert ARG)


[GNU Emacs Manual: Inserting Text](http://www.gnu.org/software/emacs/manual/html_node/emacs/Inserting-Text.html)


## 参考文章
- [Emacs/Emacs快捷键 - 站长百科](http://www.zzbaike.com/wiki/Emacs/Emacs%E5%BF%AB%E6%8D%B7%E9%94%AE)






