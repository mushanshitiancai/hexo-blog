---
title: 【TODO】tmux使用与配置
date: 2016-03-02 16:40:38
tags: tools
---

tmux是一个终端复用工具。就是你可以在一个终端中用tmux开很多终端。

公司使用统一的开发机开发，所以长时间登录是必须的，tmux可以保存会话，这样第二天来上班再次连接开发机时，一切保持原样，很方便，现在已经是不可或缺的工具之一了。

tmux使用分层的思想来管理终端：会话(session)>窗口(window)>面板(panel)。一个tmux是可以被多个客户端(client)访问的。

tmux命令常用操作：

```
- 新建会话：tmux new -s xxx
- 进入会话：tmux attach -t xxx
- 关闭会话：tmux kill-session -t xxx
- 列出会话：tmux ls
```

进入tmux后，可以使用快捷键进行切换窗口等操作。tmux的快捷键都是双段的，默认的快捷键前缀为`ctrl-b`，然后可以接的快捷键有：

```
c 新建窗口
" 上下划分当前panel
% 左右划分当前panel

0-9 切换0-9号window

d 退出当前client，session会继续存在
& 关闭当前window
x 关闭当前panel

$ 重命名当前会话
, 重命名当前窗口


C-b 发送ctrl-b到tmux的终端中
C-o
C-z 挂起当前client

```


我的tmux配置。

```
# 使支持256色
set -g default-terminal "screen-256color"

# 使用vi风格的按键
set-window-option -g mode-keys vi

# 设置索引从1开始
set -g base-index 1

# 启用鼠标支持
setw -g mouse-resize-pane on
setw -g mouse-select-pane on
setw -g mouse-select-window on
setw -g mode-mouse on

# 设置状态栏的样式
set -g status-bg colour8
set -g status-fg white
#set -g status-left ""
#set -g status-right "#[fg=green]#H"

# 设置状态栏左侧侧显示的信息
#set-window-option -g status-left " #S "
set-window-option -g status-left ""
set-window-option -g status-left-fg black
set-window-option -g status-left-bg white

# 设置状态栏右侧显示的信息
set-window-option -g status-right "[#S] %Y-%m-%d %H:%M"
#set-window-option -g status-right-fg white
#set-window-option -g status-right-bg black

# 设置状态栏非当前window状态显示的格式
set-window-option -g window-status-format " #I: #W "

# 设置状态栏当前window状态显示的格式
set-window-option -g window-status-current-format " #I: #W "
set-window-option -g window-status-current-fg white
set-window-option -g window-status-current-bg colour10

# 绑定'r'为重新读取配置
bind r source-file ~/.tmux.conf \; display "Reloaded!!!!!"
```

## mouse相关配置提示错误
我在mac上使用这个配置，提示错误：

```
/Users/mazhibin/.tmux.conf:11: unknown option: mouse-resize-pane               
/Users/mazhibin/.tmux.conf:12: unknown option: mouse-select-pane
/Users/mazhibin/.tmux.conf:13: unknown option: mouse-select-window
/Users/mazhibin/.tmux.conf:14: unknown option: mode-mouse
```

这是因为我mac上的tmux的版本是2.1。centos上的是1.9。而tmux2中，mouse的相关配置被重写了。只需要：

    set -g mouse on

即可。

## 配置颜色
### 啥是colour？
tmux的man文档里有这大量的`colour`，这是啥？

> colour是英式英语用法; color是美式英语用法

好吧，我承认这个问题很蠢。

### 如何在配置中指定颜色
需要指定颜色的命令中我们怎么指定颜色呢？有几种方式。

第一种，直接指定颜色字符串，可以是`black, red, green, yellow, blue, magenta, cyan, white`这八种基本颜色之一。

第二种，如果终端支持256色，可以指定为`colour0...colour255`这256种颜色之一。

第三种，可以像写css一样，指定一个十六进制颜色字符串，比如`#ffffff`，tmux会选择最接近256标准色的那个颜色来渲染。

同时还可以指定文字的属性，比如加粗，下划线等。这些属性可以叠加，用逗号隔开，`bright (or bold), dim, underscore, blink, reverse, hidden, italics`，如果你要关闭一个属性，可以在属性前面加上`no`前缀。举几个例子：

```
fg=yellow,bold,underscore,blink 
bg=black,fg=default,noreverse
```

## 扩展阅读
网上的一个回答：[地址](http://unix.stackexchange.com/a/60969)，提到了一个查看color256的脚本：

```
#!/usr/bin/env bash
for i in {0..255} ; do
    printf "\x1b[38;5;${i}mcolour${i}\n"
done
```


## 参考文章：
- [OpenBSD manual pages](http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man1/tmux.1?query=tmux&sec=1)
- [tony/tmux-config: Example tmux configuration - screen + vim key-bindings, system stat, cpu load bar.](https://github.com/tony/tmux-config)
- [Tmux 速成教程：技巧和调整 - 博客 - 伯乐在线](http://blog.jobbole.com/87584/)

